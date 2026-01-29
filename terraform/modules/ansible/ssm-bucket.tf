resource "random_id" "ssm_bucket" {
  byte_length = 4
}

resource "aws_s3_bucket" "ssm" {
  bucket = "${var.name}-ansible-ssm-${random_id.ssm_bucket.hex}"

  tags = merge(var.tags, {
    Name = "${var.name}-ansible-ssm"
  })
}

resource "aws_s3_bucket_ownership_controls" "ssm" {
  bucket = aws_s3_bucket.ssm.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "ssm" {
  bucket = aws_s3_bucket.ssm.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable these if you want versioning and default encryption.
# resource "aws_s3_bucket_versioning" "ssm" {
#   bucket = aws_s3_bucket.ssm.id
#
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
#
# resource "aws_s3_bucket_server_side_encryption_configuration" "ssm" {
#   bucket = aws_s3_bucket.ssm.id
#
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
