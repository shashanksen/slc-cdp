# -----------------------
# IAM Role for EC2 to access S3
# -----------------------
resource "aws_iam_role" "app_role" {
  name = "cdp-slc-dev-migration-app-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  tags = local.tags
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "cdp-slc-dev-migration-app-role-profile"
  role = aws_iam_role.app_role.name
}

resource "aws_iam_role_policy" "s3_access" {
  name = "cdp-slc-dev-migration-app-role-s3"
  role = aws_iam_role.app_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.staging.arn]
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = ["${aws_s3_bucket.staging.arn}/*"]
      }
    ]
  })
}
