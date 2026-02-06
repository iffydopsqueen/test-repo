locals {
  name_prefix = "${var.project}-${var.environment}"

  ssm_document_name = trimspace(var.ssm_document_name) != "" ? trimspace(var.ssm_document_name) : "${local.name_prefix}-ansible-run"

  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
  })
}

####################################################################
## GitHub Actions OIDC (module)
####################################################################

module "github_actions" {
  source = "../../modules/gha"

  name_prefix                 = local.name_prefix
  project                     = var.project
  environment                 = var.environment
  openid_connect_url          = var.openid_connect_url
  client_id_list              = var.client_id_list
  github_actions_subjects     = var.github_actions_subjects
  role_name                   = var.github_actions_role_name
  ssm_document_name           = local.ssm_document_name

  tags = local.tags
}
