output "zone_name" {
  value       = module.dns.zone_name
  description = "Route53 hosted zone name."
}

output "zone_id" {
  value       = module.dns.zone_id
  description = "Route53 hosted zone ID."
}

output "name_servers" {
  value       = module.dns.name_servers
  description = "Route53 name servers to set at the registrar."
}

output "alb_record_fqdn" {
  value       = module.dns.record_fqdn
  description = "DNS record that points to the ALB."
}
