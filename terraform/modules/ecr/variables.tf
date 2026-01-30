variable "repositories" {
  type        = set(string)
  description = "ECR repository names to create"
}

variable "force_delete" {
  type        = bool
  description = "Whether to force delete repositories even if they contain images"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all ECR repositories"
  default     = {}
}
