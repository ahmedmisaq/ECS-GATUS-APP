output "Gatus_VPC_id" {
  description = "Gatus VPC ID"
  value       = aws_vpc.Gatus_VPC.id
}

output "Public_subnet_ids" {
  description = "Public Subnet ID's"
  value       = aws_subnet.Gatus_Public_Subnet[*].id
}

output "Private_subnet_ids" {
  description = "Private Subnet ID's"
  value       = aws_subnet.Gatus_Private_Subnet[*].id
}
