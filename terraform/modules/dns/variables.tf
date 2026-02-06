variable "zone_name" {
  type        = string
  description = "Public hosted zone name (e.g., begindevops.com)."
}

variable "record_name" {
  type        = string
  description = "DNS record name to point at the ALB (\"@\" for apex or a subdomain like \"www\")."
  default     = "@"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name to target in the Route53 alias record."
}

variable "alb_zone_id" {
  type        = string
  description = "Route53 zone ID for the ALB alias target."
}

variable "create_zone" {
  type        = bool
  description = "Whether to create the hosted zone. Set false to use an existing zone."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the hosted zone."
  default     = {}
}
