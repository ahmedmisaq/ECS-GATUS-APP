variable "ecr_url" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "sg_ecs" {
  description = "Gatus Security Group for ecs"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private Subnet CIDR for Gatus infrastructure"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ALB Target Gropup ARN"
  type        = string
}

variable "ecr_sha" {
  description = "ECR Commit Sha"
  type = string
}