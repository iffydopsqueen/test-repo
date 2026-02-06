locals {
  name_prefix     = "${var.project}-${var.environment}"
  infra_state_key = trimspace(var.infra_state_key) != "" ? trimspace(var.infra_state_key) : "${var.environment}/terraform.tfstate"
  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
  })
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = local.infra_state_key
    region = var.state_region
  }
}

module "dns" {
  source = "../modules/dns"

  zone_name    = var.route53_zone_name
  record_name  = var.route53_record_name
  alb_dns_name = data.terraform_remote_state.infra.outputs.alb_dns_name
  alb_zone_id  = data.terraform_remote_state.infra.outputs.alb_zone_id

  create_zone = var.create_zone
  tags        = local.tags
}
