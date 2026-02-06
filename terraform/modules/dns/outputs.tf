output "zone_name" {
  value       = local.zone_name
  description = "Hosted zone name."
}

output "zone_id" {
  value       = local.zone_id
  description = "Hosted zone ID."
}

output "name_servers" {
  value       = local.name_servers
  description = "Name servers for the hosted zone."
}

output "record_fqdn" {
  value       = aws_route53_record.alb.fqdn
  description = "FQDN of the ALB alias record."
}
