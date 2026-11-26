output "ecr_url" {
  description = "ECR URL"
  value       = aws_ecr_repository.Gatus_ECR.repository_url
}