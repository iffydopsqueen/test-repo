output "db_instance_id" {
  value       = aws_db_instance.this.id
  description = "ID of the RDS instance"
}

output "db_endpoint" {
  value       = aws_db_instance.this.address
  description = "Endpoint address of the RDS instance"
}

output "db_port" {
  value       = aws_db_instance.this.port
  description = "Port exposed by the RDS instance"
}

output "db_sg_id" {
  value       = aws_security_group.db.id
  description = "Security group ID for the RDS instance"
}
