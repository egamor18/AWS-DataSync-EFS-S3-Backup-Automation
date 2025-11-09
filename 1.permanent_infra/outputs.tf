output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "efs_id" {
  value = aws_efs_file_system.web_data.id
}


output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

#--------------------arns-----------------------
output "efs_arn" {
  value = aws_efs_file_system.web_data.arn
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "public_subnets_arn" {
  value = module.vpc.public_subnet_arns
}

output "security_group_arn" {
  value = aws_security_group.ec2_sg.arn
}