variable "alb" {
  description = "Gatus application load balanacer"
  type        = string
}

variable "sg" {
  description = "Gatus Security Group"
  type        = string
}

variable "s3_alb" {
  description = "Gatus Alb S3 bucket"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR for Gatus infrastructure"
  type        = list(string)
}

variable "bucket_name" {
  description = "Gatus S3 Bucket Name"
  type        = string
  default     = "gatus-alb-logs-345678"
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "certificate_arn" {
  description = "certificate arn"
  type        = string
}