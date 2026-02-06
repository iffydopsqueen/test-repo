output "role_arn" {
  value       = aws_iam_role.this.arn
  description = "GitHub Actions IAM role ARN"
}

output "role_name" {
  value       = aws_iam_role.this.name
  description = "GitHub Actions IAM role name"
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.this.arn
  description = "OIDC provider ARN"
}

output "ssm_document_name" {
  value       = aws_ssm_document.ansible_run.name
  description = "SSM document name for running Ansible on control node"
}

output "ssm_document_arn" {
  value       = aws_ssm_document.ansible_run.arn
  description = "SSM document ARN for running Ansible on control node"
}
