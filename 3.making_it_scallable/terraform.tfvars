aws_region = "eu-central-1"
#ami_id         = "ami-0abcdef1234567890"  # Replace with latest Amazon Linux 2 AMI
instance_type  = "t3.micro"
number_of_ec2s = 2
min_ec2        = 1
max_ec2        = 4
ec2_user_data  = "./user_data.sh.tmpl"
