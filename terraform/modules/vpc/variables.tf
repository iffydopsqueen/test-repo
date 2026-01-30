variable "name" {
  type        = string
  description = "Name prefix applied to VPC resources (e.g., project-environment)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to use for subnets (must match subnet CIDR list lengths)"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets in each AZ (index aligned to azs)"
}

variable "private_app_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private app subnets in each AZ (index aligned to azs)"
}

variable "private_db_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private DB subnets in each AZ (index aligned to azs)"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create NAT gateways for private app subnet egress"
  default     = true
}

variable "enable_ssm_endpoints" {
  type        = bool
  description = "Whether to create VPC interface endpoints for SSM (ssm, ssmmessages, ec2messages)"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources in this module"
  default     = {}
}
