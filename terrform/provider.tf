terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.68.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "eu-north-1"

  default_tags {
    tags = {
      project     = "ecs-gatus"
      managedby   = "tf"
      environment = "production"
    }
  }
}
