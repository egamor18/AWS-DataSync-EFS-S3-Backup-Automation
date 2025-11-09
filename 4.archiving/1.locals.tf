# -----------------------------
# Locals for cleaner references
# -----------------------------
locals {
  vpc_id         = data.terraform_remote_state.infra.outputs.vpc_id
  subnets        = data.terraform_remote_state.infra.outputs.public_subnets
  sg_id          = data.terraform_remote_state.infra.outputs.security_group_id
  efs_id         = data.terraform_remote_state.infra.outputs.efs_id
  account_number = data.aws_caller_identity.current.account_id


  vpc_arn     = data.terraform_remote_state.infra.outputs.vpc_arn
  subnets_arn = data.terraform_remote_state.infra.outputs.public_subnets_arn
  sg_arn      = data.terraform_remote_state.infra.outputs.security_group_arn
  efs_arn     = data.terraform_remote_state.infra.outputs.efs_arn
}
