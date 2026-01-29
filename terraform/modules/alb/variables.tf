variable "name" {
  type        = string
  description = "Name for the Application Load Balancer"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ALB and target group are created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB (typically across two AZs)"
}

variable "internal" {
  type        = bool
  description = "Whether the ALB is internal (true) or internet-facing (false)"
  default     = false
}

variable "listener_port" {
  type        = number
  description = "Listener port for the ALB (e.g., 443 for HTTPS)"
  default     = 443
}

variable "listener_protocol" {
  type        = string
  description = "Listener protocol for the ALB (HTTP or HTTPS)"
  default     = "HTTPS"

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.listener_protocol)
    error_message = "listener_protocol must be HTTP or HTTPS"
  }
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS listeners"
  default     = null

  validation {
    condition     = var.listener_protocol != "HTTPS" || var.certificate_arn != null
    error_message = "certificate_arn is required when listener_protocol is HTTPS"
  }
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy for HTTPS listeners"
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "target_port" {
  type        = number
  description = "Target group port for application traffic"
  default     = 80
}

variable "target_protocol" {
  type        = string
  description = "Target group protocol (HTTP or HTTPS)"
  default     = "HTTP"
}

variable "target_type" {
  type        = string
  description = "Target type for the target group (instance or ip)"
  default     = "instance"

  validation {
    condition     = contains(["instance", "ip"], var.target_type)
    error_message = "target_type must be instance or ip"
  }
}

variable "health_check_path" {
  type        = string
  description = "Health check path for target group (HTTP/HTTPS only)"
  default     = "/"
}

variable "health_check_interval" {
  type        = number
  description = "Health check interval in seconds"
  default     = 30
}

variable "health_check_timeout" {
  type        = number
  description = "Health check timeout in seconds"
  default     = 5
}

variable "healthy_threshold" {
  type        = number
  description = "Number of consecutive successes before considering target healthy"
  default     = 2
}

variable "unhealthy_threshold" {
  type        = number
  description = "Number of consecutive failures before considering target unhealthy"
  default     = 2
}

variable "health_check_matcher" {
  type        = string
  description = "HTTP response codes to match for a successful health check"
  default     = "200-399"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all ALB-related resources"
  default     = {}
}
