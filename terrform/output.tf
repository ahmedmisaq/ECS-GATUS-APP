output "gatus_vpc_id" {
  description = "Gatus VPC"
  value       = module.networking.Gatus_VPC_id
}

output "public_subnet_ids" {
  description = "Public subnet ids"
  value       = module.networking.Public_subnet_ids
}
output "private_subnet_ids" {
  description = "Private subnet ids"
  value       = module.networking.Private_subnet_ids
}

output "ecr_url" {
  description = "ECR URL"
  value       = module.ecr.ecr_url
}

output "sg" {
  description = "Gatus Security Group ID"
  value       = module.sg.Gatus_Security_Group_Id
}

output "sg_ecs" {
  description = "Gatus Security Group ECS ID"
  value       = module.sg.Gatus_Security_Group_ecs_id
}

output "aws_alb_id" {
  description = "Gatus application load balancer"
  value       = module.alb.aws_alb_id
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "certificate_arn" {
  value       = module.dns.certificate_arn
  description = "The verified ARN of the ACM certificate."
}

output "iam_role_arn" {
  description = "IAM Role ARN"
  value       = module.IAM.iam_role_arn
}

output "alb_target_group_arn" {
  value = module.alb.alb_target_group_arn
}