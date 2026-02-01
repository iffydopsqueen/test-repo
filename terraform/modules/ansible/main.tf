resource "aws_security_group" "this" {
  name_prefix = "${var.name}-ansible-sg-"
  vpc_id      = var.vpc_id

  ingress = []

  egress {
    description = "Allow HTTP egress for package repositories."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTPS egress for SSM, repos, and Git."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-ansible-sg"
  })
}

resource "aws_iam_role" "this" {
  name_prefix = "${var.name}-ansible-role-"

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

resource "aws_iam_policy" "ansible_ssm" {
  name_prefix = "${var.name}-ansible-ssm-"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands",
          "ssm:StartSession",
          "ssm:TerminateSession",
          "ssm:ResumeSession",
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ssm:DescribeInstanceInformation",
          "ssm:DescribeInstanceProperties",
          "ssm:DescribeDocument",
          "ssm:ListDocuments"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ansible_ssm_bucket" {
  name_prefix = "${var.name}-ansible-ssm-bucket-"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.ssm.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.ssm.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = {
    ssm_core    = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ansible_ssm = aws_iam_policy.ansible_ssm.arn
  }

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "ssm_bucket" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ansible_ssm_bucket.arn
}

resource "aws_iam_instance_profile" "this" {
  name_prefix = "${var.name}-ansible-profile-"
  role        = aws_iam_role.this.name
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  iam_instance_profile   = aws_iam_instance_profile.this.name

  associate_public_ip_address = false

  tags = merge(var.tags, {
    Name = "${var.name}-ansible-control"
    Role = "ansible-control"
  })
}
