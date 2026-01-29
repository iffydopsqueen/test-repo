variable "name" {
  type        = string
  description = "Secrets Manager secret name"
}

variable "username" {
  type        = string
  description = "Database username stored in the secret"
}

variable "password" {
  type        = string
  description = "Database password stored in the secret"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the secret"
  default     = {}
}
