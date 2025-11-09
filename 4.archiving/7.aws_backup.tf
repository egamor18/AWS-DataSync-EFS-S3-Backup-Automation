/*

# ----------------------------------------------------
# Backup Vault to hold recovery points
# ----------------------------------------------------
resource "aws_backup_vault" "efs_backup_vault" {
  name        = "efs-archive-backup-vault"
  kms_key_arn = null  # Optional: Use a custom KMS key if required

  tags = {
    Purpose = "EFS Archive Backups"
  }
}



# ----------------------------------------------------
# Backup Plan for EFS
# ----------------------------------------------------
resource "aws_backup_plan" "efs_backup_plan" {
  name = "efs-archive-backup-plan"

  rule {
    rule_name         = "daily-efs-backup"
    target_vault_name = aws_backup_vault.efs_backup_vault.name
    schedule          = var.datasync_schedule
    start_window      = 60                    # Start within 1 hour
    completion_window = 180                   # Complete within 3 hours

    lifecycle {
      delete_after = 1   # Retain backups for 30 days
    }

    recovery_point_tags = {
      Type = "Daily"
    }
  }
}


# ----------------------------------------------------
# Backup Selection: Choose EFS file system to back up
# ----------------------------------------------------
resource "aws_backup_selection" "efs_backup_selection" {
  name         = "efs-archive-selection"
  iam_role_arn = aws_iam_role.backup_service_role.arn
  plan_id      = aws_backup_plan.efs_backup_plan.id

  resources = [
    data.aws_efs_file_system.efs.arn
  ]
}


# ----------------------------------------------------
# IAM Role for AWS Backup to access EFS
# ----------------------------------------------------
resource "aws_iam_role" "backup_service_role" {
  name = "AWSBackupServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "backup.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_service_role_policy" {
  role       = aws_iam_role.backup_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}


*/