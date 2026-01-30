data "aws_region" "current" {}

locals {
  # Map each AZ to the corresponding CIDR to ensure deterministic subnet placement.
  public_subnet_map = {
    for idx, az in var.azs : az => var.public_subnet_cidrs[idx]
  }
  private_app_subnet_map = {
    for idx, az in var.azs : az => var.private_app_subnet_cidrs[idx]
  }
  private_db_subnet_map = {
    for idx, az in var.azs : az => var.private_db_subnet_cidrs[idx]
  }
  # Flatten all tiers into a single map for shared subnet creation/associations.
  subnet_map = merge(
    { for az, cidr in local.public_subnet_map : "${az}-public" => { az = az, cidr = cidr, tier = "public" } },
    { for az, cidr in local.private_app_subnet_map : "${az}-private-app" => { az = az, cidr = cidr, tier = "private-app" } },
    { for az, cidr in local.private_db_subnet_map : "${az}-private-db" => { az = az, cidr = cidr, tier = "private-db" } }
  )
  ssm_service_names = {
    ssm         = "com.amazonaws.${data.aws_region.current.region}.ssm"
    ssmmessages = "com.amazonaws.${data.aws_region.current.region}.ssmmessages"
    ec2messages = "com.amazonaws.${data.aws_region.current.region}.ec2messages"
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr

  # DNS support/hostnames are enabled for ALB, RDS, and service discovery
  enable_dns_support   = true
  enable_dns_hostnames = true

  lifecycle {
    precondition {
      condition     = length(var.public_subnet_cidrs) == length(var.azs)
      error_message = "public_subnet_cidrs must have the same length as azs."
    }
    precondition {
      condition     = length(var.private_app_subnet_cidrs) == length(var.azs)
      error_message = "private_app_subnet_cidrs must have the same length as azs."
    }
    precondition {
      condition     = length(var.private_db_subnet_cidrs) == length(var.azs)
      error_message = "private_db_subnet_cidrs must have the same length as azs."
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

resource "aws_subnet" "this" {
  for_each = local.subnet_map

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.value.az
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = each.value.tier == "public" # Public subnets assign public IPs for ALB/NAT

  tags = merge(var.tags, {
    Name = (
      each.value.tier == "public" ? "${var.name}-public-${each.value.az}" :
      each.value.tier == "private-app" ? "${var.name}-app-${each.value.az}" :
      "${var.name}-db-${each.value.az}"
    )
    Tier = each.value.tier
  })
}

resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? local.public_subnet_map : {}

  domain = "vpc"
  depends_on    = [aws_internet_gateway.this] # To avoid IGW hanging during destroy

  tags = merge(var.tags, {
    Name = "${var.name}-nat-eip-${each.key}"
  })
}

resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? local.public_subnet_map : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.this["${each.key}-public"].id
  depends_on    = [aws_internet_gateway.this] # To avoid IGW hanging during destroy

  tags = merge(var.tags, {
    Name = "${var.name}-nat-${each.key}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.name}-public-rt"
  })
}

resource "aws_route_table" "private_app" {
  for_each = local.private_app_subnet_map

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.this[each.key].id
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-app-rt-${each.key}"
  })
}

resource "aws_route_table" "private_db" {
  for_each = local.private_db_subnet_map

  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-db-rt-${each.key}"
  })
}

resource "aws_route_table_association" "subnets" {
  for_each = local.subnet_map

  subnet_id = aws_subnet.this[each.key].id
  route_table_id = (
    each.value.tier == "public" ? aws_route_table.public.id :
    each.value.tier == "private-app" ? aws_route_table.private_app[each.value.az].id :
    aws_route_table.private_db[each.value.az].id
  )
}

resource "aws_security_group" "ssm_endpoints" {
  for_each = var.enable_ssm_endpoints ? { this = true } : {}

  name_prefix = "${var.name}-ssm-endpoints-"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from private app subnets to SSM endpoints."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_app_subnet_cidrs
  }

  egress {
    description = "Allow all egress for endpoint responses."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-ssm-endpoints-sg"
  })
}

resource "aws_vpc_endpoint" "ssm" {
  for_each = var.enable_ssm_endpoints ? local.ssm_service_names : {}

  vpc_id              = aws_vpc.this.id
  vpc_endpoint_type   = "Interface"
  service_name        = each.value
  private_dns_enabled = true

  subnet_ids         = [for key, subnet in aws_subnet.this : subnet.id if local.subnet_map[key].tier == "private-app"]
  security_group_ids = [aws_security_group.ssm_endpoints["this"].id]

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}-endpoint"
  })
}
