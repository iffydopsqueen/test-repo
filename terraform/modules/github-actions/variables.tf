# variable "name_prefix" {
#   type        = string
#   description = "Name prefix for GitHub Actions resources"
# }

# variable "project" {
#   type        = string
#   description = "Project tag used for least-privilege scoping"
# }

# variable "environment" {
#   type        = string
#   description = "Environment tag used for least-privilege scoping"
# }

# variable "openid_connect_url" {
#   type        = string
#   description = "OIDC provider URL for GitHub Actions"
# }

# variable "client_id_list" {
#   type        = list(string)
#   description = "OIDC client IDs (audiences)"
# }

# variable "github_actions_subjects" {
#   type        = list(string)
#   description = "GitHub Actions OIDC subject patterns allowed to assume role"
# }

# variable "role_name" {
#   type        = string
#   description = "IAM role name for GitHub Actions"
# }

# variable "tags" {
#   type        = map(string)
#   description = "Tags applied to GitHub Actions resources"
#   default     = {}
# }
