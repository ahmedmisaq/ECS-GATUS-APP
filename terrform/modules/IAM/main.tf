// ECR Permissions
resource "aws_iam_role" "ecs_task_execution" {
  name = "gatus-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com",
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ecr_permission" {
    name = "gatus-app-ecr"
    path = "/"
    description = "Allow ECS Fargate to pull the Gatus container image from ECR"

    policy = jsonencode({
    "Version":"2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
})
}

resource "aws_iam_role_policy_attachment" "role_ecr_policy_attachement" {
    role = aws_iam_role.ecs_task_execution.name
    policy_arn = aws_iam_policy.ecr_permission.arn
}