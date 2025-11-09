# ----------------------------------------------------
# SNS Topic for DataSync Notifications
# ----------------------------------------------------
resource "aws_sns_topic" "datasync_notifications" {
  name = "datasync-task-notifications"

  tags = {
    Purpose = "EFS to S3 DataSync Notifications"
  }
}

# ----------------------------------------------------
# SNS Subscription (Email)
# ----------------------------------------------------
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.datasync_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email  # Example: "admin@example.com"
}


# ----------------------------------------------------
# EventBridge Rule for DataSync Task Events
# ----------------------------------------------------
resource "aws_cloudwatch_event_rule" "datasync_task_events" {
  name        = "datasync-task-events"
  description = "Triggers when DataSync task succeeds or fails"

  event_pattern = jsonencode({
    "source": ["aws.datasync"],
    "detail-type": ["DataSync Task Execution State Change"],
    "detail": {
      "State": ["SUCCESS", "ERROR", "FAILED"]
    }
  })
}


# ----------------------------------------------------
# EventBridge Target: Send notifications to SNS
# ----------------------------------------------------
/*
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.datasync_task_events.name
  arn       = aws_sns_topic.datasync_notifications.arn
  target_id = "send-to-sns"
}
*/

resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.datasync_task_events.name
  arn       = aws_sns_topic.datasync_notifications.arn
  target_id = "send-to-sns"

  input_transformer {
    input_paths = {
      "state"     = "$.detail.State"
      "task_arn"  = "$.resources[0]"
      "time"      = "$.time"
      "region"    = "$.region"
    }

    input_template = <<EOF
{
  "default": "DataSync Task Notification:\\n\\nTask ARN: <task_arn>\\nRegion: <region>\\nTime: <time>\\nState: <state>"
}
EOF
  }
}



# ----------------------------------------------------
# IAM Policy allowing EventBridge to publish to SNS
# ----------------------------------------------------
resource "aws_sns_topic_policy" "allow_eventbridge_publish" {
  arn = aws_sns_topic.datasync_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sns:Publish",
        Resource = aws_sns_topic.datasync_notifications.arn
      }
    ]
  })
}
