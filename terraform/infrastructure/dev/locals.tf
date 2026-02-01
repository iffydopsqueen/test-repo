locals {
  name_prefix = "${var.project}-${var.environment}"

  tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
  })

  ansible_bootstrap_commands = [
    "sudo apt-get update -y",
    "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip python3-full git curl unzip jq",
    "if ! command -v aws >/dev/null 2>&1; then curl -sSLo /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip && unzip -q /tmp/awscliv2.zip -d /tmp && sudo /tmp/aws/install; fi",
    "sudo python3 -m venv /opt/ansible-venv",
    "sudo /opt/ansible-venv/bin/pip install --upgrade pip",
    "sudo /opt/ansible-venv/bin/pip install ansible boto3 botocore",
    "sudo ln -sf /opt/ansible-venv/bin/ansible-playbook /usr/local/bin/ansible-playbook",
    "sudo ln -sf /opt/ansible-venv/bin/ansible-galaxy /usr/local/bin/ansible-galaxy",
    "sudo ln -sf /opt/ansible-venv/bin/ansible-inventory /usr/local/bin/ansible-inventory",
    "sudo mkdir -p /usr/share/ansible/collections",
    "sudo /opt/ansible-venv/bin/ansible-galaxy collection install amazon.aws -p /usr/share/ansible/collections",
    "curl -sSLo /tmp/session-manager-plugin.deb https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb",
    "sudo dpkg -i /tmp/session-manager-plugin.deb || sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -y",
  ]

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
