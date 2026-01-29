output "alb_arn" {
  value       = aws_lb.this.arn
  description = "ARN of the Application Load Balancer"
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "alb_sg_id" {
  value       = aws_security_group.alb.id
  description = "Security group ID attached to the ALB"
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "ARN of the ALB target group"
}

output "listener_arn" {
  value       = aws_lb_listener.this.arn
  description = "ARN of the ALB listener"
}
