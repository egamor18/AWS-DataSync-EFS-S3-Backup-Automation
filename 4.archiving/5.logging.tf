
#---logging ---- to help troubleshooting --------------
resource "aws_cloudwatch_log_group" "datasync_logs" {
  name              = "/aws/datasync/${var.bucket_name_prefix}"
  retention_in_days = 14

  tags = {
    Name = "datasync-logs"
  }
}


data "aws_iam_policy_document" "datasync_cw_access" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    # Grant permission to the DataSync Service Principal
    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }

    # The resource policy applies broadly across the region
    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_resource_policy" "datasync_policy" {
  policy_name     = "datasync-log-writer-policy"
  policy_document = data.aws_iam_policy_document.datasync_cw_access.json
}