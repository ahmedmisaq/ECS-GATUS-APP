output "Gatus_Security_Group_Id" {
  description = "Gatus Security Group ID"
  value       = aws_security_group.alb.id
}

output "Gatus_Security_Group_ecs_id" {
  description = "Gatus Security Group ECS ID"
  value       = aws_security_group.ecs.id
}