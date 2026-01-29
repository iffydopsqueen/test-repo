output "vpc_id" {
  value       = aws_vpc.this.id
  description = "ID of the VPC created by this module"
}

output "public_subnet_ids" {
  value       = [for key, subnet in aws_subnet.this : subnet.id if local.subnet_map[key].tier == "public"]
  description = "List of public subnet IDs (one per AZ)"
}

output "private_app_subnet_ids" {
  value       = [for key, subnet in aws_subnet.this : subnet.id if local.subnet_map[key].tier == "private-app"]
  description = "List of private app subnet IDs (one per AZ)"
}

output "private_db_subnet_ids" {
  value       = [for key, subnet in aws_subnet.this : subnet.id if local.subnet_map[key].tier == "private-db"]
  description = "List of private DB subnet IDs (one per AZ)"
}

output "igw_id" {
  value       = aws_internet_gateway.this.id
  description = "ID of the Internet Gateway attached to the VPC"
}

output "nat_gateway_ids" {
  value       = [for nat in aws_nat_gateway.this : nat.id]
  description = "List of NAT gateway IDs (one per AZ when enabled)"
}
