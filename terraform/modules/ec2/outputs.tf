output "instance_ids" {
  value       = [for instance in aws_instance.this : instance.id]
  description = "IDs of the application EC2 instances"
}

output "private_ips" {
  value       = [for instance in aws_instance.this : instance.private_ip]
  description = "Private IP addresses of the application EC2 instances"
}

output "app_sg_id" {
  value       = aws_security_group.app.id
  description = "Security group ID for the application instance"
}

output "iam_role_arn" {
  value       = aws_iam_role.this.arn
  description = "IAM role ARN attached to the application instance"
}
