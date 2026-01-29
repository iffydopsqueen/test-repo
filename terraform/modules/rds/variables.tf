variable "name" {
  type        = string
  description = "Name prefix for RDS resources (e.g., project-environment)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the RDS instance and security group are created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private DB subnet IDs for the DB subnet group"
}

variable "db_name" {
  type        = string
  description = "Initial database name to create"
}

variable "username" {
  type        = string
  description = "Master username for the database"
}

variable "password" {
  type        = string
  description = "Master password for the database"
  sensitive   = true
}

variable "engine" {
  type        = string
  description = "Database engine (e.g., mysql or postgres)"
  default     = "mysql"
}

variable "engine_version" {
  type        = string
  description = "Database engine version."
  default     = "8.0"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class (e.g., db.t3.micro)"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
  default     = 20
}

variable "storage_type" {
  type        = string
  description = "Storage type (e.g., gp3, gp2)"
  default     = "gp3"
}

variable "port" {
  type        = number
  description = "Database port number"
  default     = 3306
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment for higher availability"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
  default     = 7
}

variable "apply_immediately" {
  type        = bool
  description = "Apply changes immediately (use false to apply during the maintenance window)"
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Enable deletion protection to prevent accidental deletes"
  default     = false
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on deletion (false is safer for production)"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all RDS-related resources"
  default     = {}
}
