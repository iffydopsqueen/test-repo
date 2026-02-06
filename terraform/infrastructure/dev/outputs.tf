output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "ALB DNS name (use as a DNS alias/CNAME target)"
}

output "alb_zone_id" {
  value       = module.alb.alb_zone_id
  description = "Route53 zone ID for the ALB (used for alias records)"
}

output "rds_endpoint" {
  value       = module.rds.db_endpoint
  description = "RDS endpoint address for application connectivity"
}

output "secrets_manager_arn" {
  value       = module.secrets.secret_arn
  description = "Secrets Manager ARN storing DB credentials"
}

output "ec2_instance_ids" {
  value       = module.ec2.instance_ids
  description = "Application EC2 instance IDs"
}

output "ansible_control_instance_id" {
  value       = module.ansible.instance_id
  description = "Ansible control node instance ID"
}

output "ansible_ssm_bucket_name" {
  value       = module.ansible.ssm_bucket_name
  description = "S3 bucket used by Ansible SSM connection plugin for file transfers"
}

output "ecr_repo_urls" {
  value       = module.ecr.repository_urls
  description = "Map of ECR repository URLs for application images"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID created for this environment"
}
