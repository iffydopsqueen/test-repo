resource "aws_secretsmanager_secret" "this" {
  name = var.name

  # Keep a short recovery window to protect against accidental deletions (zero for dev, 7 for prod)
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id

  secret_string = jsonencode({
    username = var.username
    password = var.password
  })
}
