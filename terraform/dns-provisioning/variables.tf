variable "region" {
  type        = string
  description = "AWS region for the provider (Route53 is global but requires a region)."
}

variable "project" {
  type        = string
  description = "Project name used for tagging and naming."
}

variable "environment" {
  type        = string
  description = "Environment name (dev/stg/prd)."
}

variable "route53_zone_name" {
  type        = string
  description = "Public hosted zone name (e.g., begindevops.com)."
}

variable "route53_record_name" {
  type        = string
  description = "DNS record name to point at the ALB (\"@\" for apex or a subdomain like \"www\")."
  default     = "@"
}

variable "create_zone" {
  type        = bool
  description = "Whether to create the hosted zone. Set false to use an existing zone."
  default     = true
}

variable "state_bucket" {
  type        = string
  description = "S3 bucket where the infra state is stored."
  default     = "wordpress-ansible-app"
}

variable "state_region" {
  type        = string
  description = "Region where the infra state bucket lives."
  default     = "us-east-1"
}

variable "infra_state_key" {
  type        = string
  description = "S3 key for the infra state (e.g., dev/terraform.tfstate). Leave blank to default from environment."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Additional tags applied to resources."
  default     = {}
}
