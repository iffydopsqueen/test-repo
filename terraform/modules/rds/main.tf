resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db-"
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(var.tags, {
    Name = "${var.name}-db-sg"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-db-subnets"
  })
}

resource "aws_db_instance" "this" {
  identifier = "${var.name}-db"

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = true # Encryption is enforced for data-at-rest

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  multi_az               = var.multi_az
  backup_retention_period = var.backup_retention_period
  apply_immediately       = var.apply_immediately
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = false # Private DB tier only; never public

  tags = merge(var.tags, {
    Name = "${var.name}-db"
  })

  depends_on = [aws_db_subnet_group.this]
}
