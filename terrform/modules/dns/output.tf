output "certificate_arn" {
  value       = aws_acm_certificate_validation.certificate_validation.certificate_arn
  description = "The verified ARN of the ACM certificate."
}