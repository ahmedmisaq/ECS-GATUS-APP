output "aws_alb_id" {
  description = "Gatus application load balancer"
  value       = aws_alb.Gatus_alb.id
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "alb_target_group_arn" {
  value = aws_alb_target_group.alb_target_group.arn
}