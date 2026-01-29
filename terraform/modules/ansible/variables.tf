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

variable "tags" {
  type        = map(string)
  description = "Tags applied to control node resources"
  default     = {}
}
