variable "domain_name" {
  description = "Domain name for the ACM certificate"
  type        = string
}

variable "cloudflare_zone" {
  description = "Cloudflare zone"
  type        = string
  default     = "aisaq.co.uk"
}

variable "cloudflare_dns_name" {
  description = "Cloudflare DNS Name"
  type        = string
  default     = "gatus.aisaq.co.uk"
}