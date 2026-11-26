variable "vpc_cidr" {
  description = "CIDR block for the Gatus VPC"
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
