locals {
  zone_name   = trimsuffix(var.zone_name, ".")
  record_name = var.record_name == "@" ? local.zone_name : var.record_name
}

resource "aws_route53_zone" "primary" {
  count = var.create_zone ? 1 : 0

  name          = local.zone_name
  comment       = "Managed by Terraform"
  force_destroy = false

  tags = var.tags
}

data "aws_route53_zone" "primary" {
  count        = var.create_zone ? 0 : 1
  name         = local.zone_name
  private_zone = false
}

locals {
  zone_id      = var.create_zone ? aws_route53_zone.primary[0].zone_id : data.aws_route53_zone.primary[0].zone_id
  name_servers = var.create_zone ? aws_route53_zone.primary[0].name_servers : data.aws_route53_zone.primary[0].name_servers
}

resource "aws_route53_record" "alb" {
  zone_id = local.zone_id
  name    = local.record_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  allow_overwrite = true
}
