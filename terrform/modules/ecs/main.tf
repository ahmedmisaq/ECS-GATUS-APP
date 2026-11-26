resource "aws_ecs_cluster" "main" {
  name = "gatus-app"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecs_task_definition" "gatus-app" {
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    family = "gatus-app"
    cpu = 256
    memory = 512
    
    
    container_definitions = jsonencode([
    {
      name      = "gatus"
      image     = "${var.ecr_url}:${var.ecr_sha}"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 8080
        }
      ]
    },
  ])
  execution_role_arn = var.iam_role_arn
}


resource "aws_ecs_service" "gatus_service" {
  name = "gatus_ecs"
  cluster = aws_ecs_cluster.gatus_cluster.id
  task_definition = aws_ecs_task_definition.gatus-app.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    assign_public_ip = false
    security_groups = [var.sg_ecs]
    subnets = var.private_subnet_ids
  }

 load_balancer {
   target_group_arn = var.target_group_arn
   container_name   = "gatus"
   container_port   = 8080
 }


}


resource "aws_ecs_cluster" "gatus_cluster" {
  name = "gatus-app"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}