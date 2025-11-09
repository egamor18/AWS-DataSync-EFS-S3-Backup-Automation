
# -----------------------------
# obtain ami_id dynamically
# -----------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}



# -----------------------------
# Launch Template
# -----------------------------


resource "aws_launch_template" "web_template" {
  name_prefix   = "efs-asg-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  # Assign public IP like the working aws_instance example
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [local.sg_id]
  }

  # Encode user data to Base64
  user_data = base64encode(templatefile(var.ec2_user_data, {
    efs_id = local.efs_id
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-asg"
    }
  }
}



# -----------------------------
# Auto Scaling Group
# -----------------------------
resource "aws_autoscaling_group" "web_asg" {
  name             = "web-asg"
  max_size         = var.max_ec2
  min_size         = var.min_ec2
  desired_capacity = var.number_of_ec2s
  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
  vpc_zone_identifier       = local.subnets
  health_check_type         = "EC2"
  health_check_grace_period = 60
  force_delete              = true
}

# ---------------------------------------------------------------
# Target Tracking Scaling Policy
# Automatically scales ASG to maintain target CPU utilization
# ---------------------------------------------------------------
resource "aws_autoscaling_policy" "target_tracking_cpu" {
  name                      = "cpu-target-tracking"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 60
  autoscaling_group_name    = aws_autoscaling_group.web_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
