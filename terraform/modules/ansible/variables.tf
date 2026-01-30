variable "name" {
  type        = string
  description = "Name prefix for the Ansible control node resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the control node is created"
}

variable "subnet_id" {
  type        = string
  description = "Private subnet ID for the control node"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the control node"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the control node"
  default     = "t3.micro"
}

variable "ssm_bucket_force_destroy" {
  type        = bool
  description = "Whether to force destroy the Ansible SSM bucket when not empty"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to control node resources"
  default     = {}
}
