variable "iam_role_arn" {
  description = "IAM role ARN"
  type        = string
}

variable "sg_ecs" {
  description = "Gatus Security Group for ecs"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private Subnet CIDR for Gatus infrastructure"
  type        = list(string)
}