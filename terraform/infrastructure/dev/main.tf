data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "random_password" "db" {
  length           = 20
  special          = true
  min_special      = 2
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "vpc" {
  source = "../../modules/vpc"

  name                     = local.name_prefix
  vpc_cidr                 = var.vpc_cidr
  azs                      = local.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  enable_nat_gateway       = var.enable_nat_gateway
  enable_ssm_endpoints     = var.enable_ssm_endpoints

  tags = local.tags
}

module "secrets" {
  source = "../../modules/asm"

  name     = "${local.name_prefix}-db-creds-v3"
  username = var.db_username
  password = random_password.db.result

  tags = local.tags
}

module "rds" {
  source = "../../modules/rds"

  name                    = local.name_prefix
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_db_subnet_ids
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db.result
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  port                    = var.db_port
  multi_az                = var.db_multi_az
  backup_retention_period = var.backup_retention_period

  tags = local.tags
}

module "alb" {
  source = "../../modules/alb"

  name              = "${local.name_prefix}-alb"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  listener_port     = var.alb_listener_port
  listener_protocol = var.alb_listener_protocol
  certificate_arn   = var.alb_certificate_arn
  target_port       = var.alb_target_port
  health_check_path = var.alb_health_check_path

  tags = local.tags
  depends_on = [module.vpc] # To avoid IGW hanging during destroy 
}

module "ecr" {
  source = "../../modules/ecr"

  repositories = var.ecr_repositories
  force_delete = var.ecr_force_delete

  tags = local.tags
}

module "ec2" {
  source = "../../modules/ec2"

  name                      = local.name_prefix
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_app_subnet_ids
  ami_id                    = var.ec2_ami_id
  instance_type             = var.ec2_instance_type
  instance_count            = var.ec2_instance_count
  secretsmanager_secret_arn = module.secrets.secret_arn
  attach_ecr_readonly       = var.attach_ecr_readonly
  user_data                 = local.app_user_data

  tags = local.tags
}

module "ansible" {
  source = "../../modules/ansible"

  name          = local.name_prefix
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.private_app_subnet_ids[0]
  ami_id        = var.ansible_ami_id
  instance_type = var.ansible_instance_type
  ssm_bucket_force_destroy = var.ansible_ssm_bucket_force_destroy

  tags = local.tags
}

####################################################################
## Bootstrap Ansible control node via SSM Document and Association
####################################################################

resource "aws_ssm_document" "ansible_bootstrap" {
  count         = var.enable_ansible_bootstrap ? 1 : 0
  name          = "${local.name_prefix}-ansible-bootstrap"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Bootstrap the Ansible control node"
    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "bootstrap"
        inputs = {
          runCommand = local.ansible_bootstrap_commands
        }
      }
    ]
  })
}

resource "aws_ssm_association" "ansible_bootstrap" {
  count = var.enable_ansible_bootstrap ? 1 : 0
  name  = aws_ssm_document.ansible_bootstrap[0].name
  wait_for_success_timeout_seconds = 900

  targets {
    key    = "tag:Role"
    values = ["ansible-control"]
  }

  depends_on = [module.ansible]
}

resource "aws_lb_target_group_attachment" "app" {
  for_each = {
    for idx in range(var.ec2_instance_count) :
    tostring(idx) => module.ec2.instance_ids[idx]
  }

  target_group_arn = module.alb.target_group_arn
  target_id        = each.value
  port             = var.alb_target_port
}

resource "aws_security_group_rule" "this" {
  for_each = local.sg_rules

  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = each.value.security_group_id

  cidr_blocks              = try(each.value.cidr_blocks, null)
  source_security_group_id = try(each.value.source_security_group_id, null)
}
