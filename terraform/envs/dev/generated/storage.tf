# -----------------------
# S3 (at least one bucket)
# -----------------------
resource "random_id" "bucket_suffix" {
  byte_length = 3
}

locals {
  s3_bucket_base = "cdp-slc-dev-staging"
  s3_bucket_name = lower(replace("${local.s3_bucket_base}-${random_id.bucket_suffix.hex}", "_", "-"))
}

resource "aws_s3_bucket" "staging" {
  bucket = local.s3_bucket_name
  tags   = merge(local.tags, { Name = local.s3_bucket_name, Purpose = "staging" })
}

resource "aws_s3_bucket_versioning" "staging" {
  bucket = aws_s3_bucket.staging.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "staging" {
  bucket = aws_s3_bucket.staging.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "staging" {
  bucket                  = aws_s3_bucket.staging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
