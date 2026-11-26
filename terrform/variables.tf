variable "region" {
  description = "aws region where resource will be created"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR for Gatus infrastructure"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR for Gatus infrastructure"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private Subnet CIDR for Gatus infrastructure"
  type        = list(string)
}

variable "ecr" {
  description = "Gatus ECR Repository"
  type        = string
}

variable "sg" {
  description = "Gatus Security Group"
  type        = string
}

variable "sg_ecs" {
  description = "Gatus Security Group for ecs"
  type        = string
}

variable "alb" {
  description = "Gatus application load balanacer"
  type        = string
}

variable "s3_alb" {
  description = "Gatus Alb S3 bucket"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the ACM certificate"
  type        = string
}

variable "ecr_sha" {
  description = "ECR Commit Sha"
  type = string
}