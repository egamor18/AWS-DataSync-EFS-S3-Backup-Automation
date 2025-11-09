
# ----------------------------------------------------
# Get current AWS identity and EFS details
# ----------------------------------------------------
data "aws_caller_identity" "current" {}


# ----------------------------------------------------
# S3 bucket for archival target
# ----------------------------------------------------
resource "aws_s3_bucket" "efs_archive" {

  bucket = "${var.bucket_name_prefix}-${local.account_number}-${var.aws_region}"

  tags = {
    Name        = "EFS Archive Bucket"
    Environment = "Production"
  }
}

# ----------------------------------------------------
# S3 bucket policy
# ----------------------------------------------------
resource "aws_s3_bucket_policy" "datasync_bucket_policy" {
  bucket = "${var.bucket_name_prefix}-${local.account_number}-${var.aws_region}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowDataSyncAccess",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.datasync_service_role.arn
        },
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:GetObjectTagging",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionTagging",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:PutObjectTagging"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name_prefix}-${local.account_number}-${var.aws_region}",
          "arn:aws:s3:::${var.bucket_name_prefix}-${local.account_number}-${var.aws_region}/*",
          #"arn:aws:s3:::${var.bucket_name_prefix}-${local.account_number}-${var.aws_region}",
          #"arn:aws:s3:::${var.bucket_name_prefix}-${local.account_number}-${var.aws_region}/*"
        ]
      }
    ]
  })
}


# ----------------------------------------------------
# S3 lifecycle configuration (modern AWS v5 style)
# ----------------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "efs_archive_lifecycle" {
  bucket = aws_s3_bucket.efs_archive.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}