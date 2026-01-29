output "instance_id" {
  value       = aws_instance.this.id
  description = "Ansible control node instance ID"
}

output "private_ip" {
  value       = aws_instance.this.private_ip
  description = "Private IP of the Ansible control node instance"
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "Security group ID for the Ansible control node"
}

output "ssm_bucket_name" {
  value       = aws_s3_bucket.ssm.bucket
  description = "S3 bucket name used by the Ansible SSM connection plugin"
}

output "ssm_bucket_arn" {
  value       = aws_s3_bucket.ssm.arn
  description = "S3 bucket ARN used by the Ansible SSM connection plugin"
}
