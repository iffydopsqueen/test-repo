locals {
  iam_policy_attachments = {
    for arn in concat(
      ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"],
      var.attach_ecr_readonly ? ["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"] : []
    ) : arn => arn
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.name}-app-"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name}-app-sg"
  })
}

resource "aws_iam_role" "this" {
  name_prefix = "${var.name}-app-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "secrets_access" {
  name_prefix = "${var.name}-secrets-"
  role        = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.secretsmanager_secret_arn
      }
    ]
  })
}

# SSM is attached by default for secure, keyless access.
resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = local.iam_policy_attachments
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "${var.name}-app-profile-"
  role        = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  for_each = { for idx in range(var.instance_count) : idx => idx }

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[each.value % length(var.subnet_ids)]
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name

  # App tier remains private; no public IPs are assigned.
  associate_public_ip_address = false
  user_data                   = var.user_data

  tags = merge(var.tags, {
    Name = format("%s-app-%02d", var.name, each.value + 1)
    Role = "app"
  })
}
