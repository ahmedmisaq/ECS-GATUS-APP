variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "allowed_subjects" {
  type = list(string)
}

variable "github_org" {
  type    = string
  default = "ahmedmisaq"
}

variable "github_repo" {
  type    = string
  default = "ECS-GATUS-APP"
}

variable "ecr_repository_name" {
  type    = string
  default = "gatus-terraform-ecr"
}

variable "ecs_task_execution_role_name" {
  type    = string
  default = "ecs_task_execution"
}

variable "ecs_task_role_name" {
  type    = string
  default = "gatus-execution-role"
}
