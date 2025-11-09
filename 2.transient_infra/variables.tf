variable "ec2_user_data" {
  description = "User data script for EC2 instances (passed in via tfvars or file)"
  type        = string
}

variable "number_of_ec2s" {
  description = " for the number of ec2s to be deployed"
  type        = number
}

variable "aws_region" {
  description = "aws region"
  type        = string
}