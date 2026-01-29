variable "name" {
  type        = string
  description = "Name prefix for app resources (e.g., project-environment)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the instance and security group are created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private app subnet IDs for the EC2 instances"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g., t3.micro)"
  default     = "t3.micro"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 app instances to create"
  default     = 1
}

variable "secretsmanager_secret_arn" {
  type        = string
  description = "ARN of the Secrets Manager secret containing DB credentials"
}

variable "attach_ecr_readonly" {
  type        = bool
  description = "Attach ECR read-only policy for pulling images"
  default     = false
}

variable "user_data" {
  type        = string
  description = "User data script for bootstrapping the instance"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to EC2, IAM, and security group resources"
  default     = {}
}
