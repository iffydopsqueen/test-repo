output "role_arn" {
  value       = module.github_actions.role_arn
  description = "GitHub Actions IAM role ARN"
}

output "role_name" {
  value       = module.github_actions.role_name
  description = "GitHub Actions IAM role name"
}

output "oidc_provider_arn" {
  value       = module.github_actions.oidc_provider_arn
  description = "OIDC provider ARN"
}

output "ssm_document_name" {
  value       = module.github_actions.ssm_document_name
  description = "SSM document name for running Ansible on control node"
}

output "ssm_document_arn" {
  value       = module.github_actions.ssm_document_arn
  description = "SSM document ARN for running Ansible on control node"
}
