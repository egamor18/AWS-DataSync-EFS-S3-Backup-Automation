aws_region         = "eu-central-1"
instance_type      = "t3.micro"
number_of_ec2s     = 2
min_ec2            = 1
max_ec2            = 4
ec2_user_data      = "./user_data.sh.tmpl"
bucket_name_prefix = "efs-to-s3-archive"
datasync_schedule  = "cron(29 22 * * ? *)" # every day at xxx UTC


notification_email = "username@example.com"

