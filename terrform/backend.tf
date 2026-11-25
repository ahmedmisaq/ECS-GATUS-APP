terraform {
  backend "s3" {
    bucket       = "gatus-remote-state432102"
    key          = "ECS_GATUS/terraform/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    use_lockfile = true
  }
}