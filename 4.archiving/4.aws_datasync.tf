

# ------------------------------------------------------------
# DataSync Service Role (Terraform-managed replica)
# ------------------------------------------------------------
resource "aws_iam_role" "datasync_service_role" {
  name = "AWSDataSyncS3BucketAccess-efs-archive-${local.account_number}-eu-cent-test"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowAWSDataSync",
        Effect = "Allow",
        Principal = {
          Service = "datasync.amazonaws.com"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_number
          },
          ArnLike = {
            "aws:SourceArn" = "arn:aws:datasync:${var.aws_region}:${local.account_number}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "DataSync S3 Access Role"
    Environment = "Production"
  }
}

# ------------------------------------------------------------
# IAM Policy: S3 Access for DataSync to efs-archive bucket
# ------------------------------------------------------------
resource "aws_iam_policy" "datasync_s3_access_policy" {
  name        = "AWSDataSyncS3BucketAccessPolicy-efs-archive"
  description = "Allows AWS DataSync to access S3 bucket efs-archive for read/write transfers"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSDataSyncS3BucketPermissions",
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ],
        Resource = "arn:aws:s3:::${var.bucket_name_prefix}-${local.account_number}-${var.aws_region}",
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = local.account_number
          }
        }
      },
      {
        Sid    = "AWSDataSyncS3ObjectPermissions",
        Effect = "Allow",
        Action = [
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
        Resource = "arn:aws:s3:::efs-archive-${local.account_number}-${var.aws_region}/*",
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = local.account_number
          }
        }
      }
    ]
  })
}

# ------------------------------------------------------------
# Attach the policy to the role
# ------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "datasync_attach_policy" {
  role       = aws_iam_role.datasync_service_role.name
  policy_arn = aws_iam_policy.datasync_s3_access_policy.arn
}

# ----------------------------------------------------
# DataSync EFS Location
# ----------------------------------------------------
resource "aws_datasync_location_efs" "efs_location" {
  efs_file_system_arn = local.efs_arn

  ec2_config {
    subnet_arn          = local.subnets_arn[0]
    security_group_arns = [local.sg_arn]
  }


  tags = {
    Name = "datasync-efs-location"
  }
}

# ----------------------------------------------------
# DataSync S3 Location
# ----------------------------------------------------
resource "aws_datasync_location_s3" "s3_location" {
  #s3_bucket_arn = "arn:aws:s3:::${var.s3_bucket_name}"

  s3_bucket_arn = aws_s3_bucket.efs_archive.arn
  subdirectory  = "/archive"

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_service_role.arn
  }

  tags = {
    Name = "datasync-s3-location"
  }
}

# ----------------------------------------------------
# DataSync Task (EFS → S3)
# ----------------------------------------------------
resource "aws_datasync_task" "efs_to_s3" {
  source_location_arn      = aws_datasync_location_efs.efs_location.arn
  destination_location_arn = aws_datasync_location_s3.s3_location.arn

  name = "efs-to-s3-transfer"

  options {
    verify_mode            = "POINT_IN_TIME_CONSISTENT"
    overwrite_mode         = "ALWAYS"
    transfer_mode          = "CHANGED"
    preserve_deleted_files = "PRESERVE"
    log_level              = "TRANSFER"
  }

  #for logging
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.datasync_logs.arn

  schedule {
    schedule_expression = var.datasync_schedule
  }

  tags = {
    Name = "datasync-task"
  }
}
