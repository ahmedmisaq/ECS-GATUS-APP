resource "aws_ecr_repository" "Gatus_ECR" {
  name                 = var.ecr
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability_exclusion_filter {
    filter      = "latest"
    filter_type = "WILDCARD"
  }
}

