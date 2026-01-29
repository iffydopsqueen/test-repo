variable "region" {
  type        = string
  description = "AWS region to deploy into (e.g., us-east-1)"
}

variable "project" {
  type        = string
  description = "Project name used for tagging and naming resources"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/stg/prd) used in resource names"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (one per AZ, index aligned to AZ list)"
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "Private app subnet CIDRs (one per AZ, index aligned to AZ list)"
}

variable "private_db_subnet_cidrs" {
  type        = list(string)
  description = "Private DB subnet CIDRs (one per AZ, index aligned to AZ list)"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to deploy NAT gateways for private app egress"
  default     = true
}

variable "enable_ssm_endpoints" {
  type        = bool
  description = "Whether to deploy VPC interface endpoints for SSM"
  default     = true
}

variable "db_name" {
  type        = string
  description = "Database name for the application"
}

variable "db_username" {
  type        = string
  description = "Database master username"
}

variable "db_engine" {
  type        = string
  description = "Database engine (mysql or postgres)"
  default     = "mysql"
}

variable "db_engine_version" {
  type        = string
  description = "Database engine version"
  default     = "8.0"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class (e.g., db.t3.micro)"
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "RDS allocated storage in GB"
  default     = 20
}

variable "db_port" {
  type        = number
  description = "Database port (3306 for MySQL, 5432 for Postgres)"
  default     = 3306
}

variable "db_multi_az" {
  type        = bool
  description = "Enable Multi-AZ for RDS high availability"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "RDS backup retention period in days (0 disables automated backups)"
  default     = 0
}

variable "alb_listener_port" {
  type        = number
  description = "ALB listener port (443 for HTTPS, 80 for HTTP)"
  default     = 443
}

variable "alb_listener_protocol" {
  type        = string
  description = "ALB listener protocol (HTTP or HTTPS)"
  default     = "HTTPS"
}

variable "alb_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS listeners"
  default     = null
}

variable "alb_target_port" {
  type        = number
  description = "Target group port for the application"
  default     = 80
}

variable "app_ingress_ports" {
  type        = list(number)
  description = "Ports to allow from the ALB to the app security group"
  default     = [80, 443]
}

variable "alb_health_check_path" {
  type        = string
  description = "Target group health check path"
  default     = "/"
}

variable "ecr_repositories" {
  type        = set(string)
  description = "ECR repositories to create for application images"
  default     = []
}

variable "ec2_ami_id" {
  type        = string
  description = "AMI ID for the app instance"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "ec2_instance_count" {
  type        = number
  description = "Number of application EC2 instances"
  default     = 1
}

variable "ansible_ami_id" {
  type        = string
  description = "AMI ID for the Ansible control node"
}

variable "ansible_instance_type" {
  type        = string
  description = "EC2 instance type for the Ansible control node"
  default     = "t3.micro"
}

variable "enable_ansible_bootstrap" {
  type        = bool
  description = "Whether to bootstrap the Ansible control node via SSM"
  default     = true
}

variable "attach_ecr_readonly" {
  type        = bool
  description = "Attach ECR read-only policy to the EC2 role"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to all resources"
  default     = {}
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
