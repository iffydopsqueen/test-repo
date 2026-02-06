locals {
  name_prefix = "${var.project}-${var.environment}"

  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
  })

  ansible_bootstrap_script = file("${path.module}/scripts/ansible-bootstrap.sh")

  ansible_bootstrap_commands = compact([
    for line in split("\n", trimspace(local.ansible_bootstrap_script)) : line
  ])

  app_user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail
    apt-get update -y
    apt-get install -y snapd
    snap install amazon-ssm-agent --classic
    systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service
  EOF

  sg_rules = merge(
    {
      alb_ingress = {
        type              = "ingress"
        from_port         = var.alb_listener_port
        to_port           = var.alb_listener_port
        protocol          = "tcp"
        cidr_blocks       = ["0.0.0.0/0"]
        security_group_id = module.alb.alb_sg_id
      }
      alb_egress_to_app = {
        type                     = "egress"
        from_port                = var.alb_target_port
        to_port                  = var.alb_target_port
        protocol                 = "tcp"
        source_security_group_id = module.ec2.app_sg_id
        security_group_id        = module.alb.alb_sg_id
      }
      app_egress_to_db = {
        type                     = "egress"
        from_port                = var.db_port
        to_port                  = var.db_port
        protocol                 = "tcp"
        source_security_group_id = module.rds.db_sg_id
        security_group_id        = module.ec2.app_sg_id
      }
      app_egress_https = {
        type              = "egress"
        from_port         = 443
        to_port           = 443
        protocol          = "tcp"
        cidr_blocks       = ["0.0.0.0/0"]
        security_group_id = module.ec2.app_sg_id
      }
      app_egress_http = {
        type              = "egress"
        from_port         = 80
        to_port           = 80
        protocol          = "tcp"
        cidr_blocks       = ["0.0.0.0/0"]
        security_group_id = module.ec2.app_sg_id
      }
      db_ingress_from_app = {
        type                     = "ingress"
        from_port                = var.db_port
        to_port                  = var.db_port
        protocol                 = "tcp"
        source_security_group_id = module.ec2.app_sg_id
        security_group_id        = module.rds.db_sg_id
      }
    },
    {
      for port in var.app_ingress_ports :
      "app_ingress_from_alb_${port}" => {
        type                     = "ingress"
        from_port                = port
        to_port                  = port
        protocol                 = "tcp"
        source_security_group_id = module.alb.alb_sg_id
        security_group_id        = module.ec2.app_sg_id
      }
    }
  )
}
