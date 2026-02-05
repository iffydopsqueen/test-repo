variable "region" {
  type        = string
  description = "AWS region to deploy into (e.g., us-east-1)"
}

variable "project" {
  type        = string
  description = "Project tag used for least-privilege scoping"
  default = "wordpress"
}

variable "environment" {
  type        = string
  description = "Environment tag used for least-privilege scoping"
  default = "dev"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to all resources"
  default     = {}
}

variable "ssm_document_name" {
  type        = string
  description = "Optional override for the custom SSM document name"
  default     = ""
}

variable "openid_connect_url" {
  type = string
  description = "OpenID Connect URL for authentication requests"
  default = "https://token.actions.githubusercontent.com"
}

variable "client_id_list" {
  type = list(string)
  description = "List of client IDs (audiences) for the OIDC provider"
  default = ["sts.amazonaws.com"]
}

variable "github_actions_subjects" {
  description = "Allowed GitHub Actions OIDC subject claims"
  type        = list(string)
  default     = ["repo:iffydopsqueen/*"]
}

variable "github_actions_role_name" {
  description = "IAM EC2 role name for GitHub Actions OIDC"
  type        = string
  default     = "github-actions-oidc-deploy-role"
}