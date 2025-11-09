

##########################
# AWS region
##########################
variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}


##########################
# EC2 instance type
##########################
variable "instance_type" {
  description = "EC2 instance type for the ASG"
  type        = string
}

##########################
# Number of EC2s in ASG
##########################
variable "number_of_ec2s" {
  description = "Desired number of EC2s"
  type        = number
}

variable "min_ec2" {
  description = "Minimum number of EC2s in ASG"
  type        = number
}

variable "max_ec2" {
  description = "Maximum number of EC2s in ASG"
  type        = number
}

##########################
# EC2 user data script
##########################
variable "ec2_user_data" {
  description = "Path to EC2 user data template"
  type        = string
}


##########################
# S3  bucket name prefix
##########################
variable "bucket_name_prefix" {
  description = "a prefix to the s3 bucket name"
  type        = string
}

##########################
# Datasynch schedule
##########################
variable "datasync_schedule" {
  description = "a cron to specify when datasync should be triggered"
  type        = string
}



##########################
# SNS NOTIFICATION
##########################
variable "notification_email" {
  description = "Email address to receive DataSync alerts"
  type        = string
}
