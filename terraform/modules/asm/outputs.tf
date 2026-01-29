output "secret_arn" {
  value       = aws_secretsmanager_secret.this.arn
  description = "ARN of the Secrets Manager secret"
}

output "secret_name" {
  value       = aws_secretsmanager_secret.this.name
  description = "Name of the Secrets Manager secret"
}
