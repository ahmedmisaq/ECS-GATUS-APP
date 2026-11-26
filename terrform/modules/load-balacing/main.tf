resource "aws_s3_bucket" "alb_logs" {
  bucket = var.bucket_name

  tags = {
    Name        = "alb-logs"
    Environment = "prod"
  }
}


resource "aws_alb" "Gatus_alb" {
  name               = var.alb
  load_balancer_type = "application"
  security_groups    = [var.sg]
  internal           = false

  subnets = var.public_subnet_cidr

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
  }

  tags = {
    Environment = "prod"
  }
  depends_on = [aws_s3_bucket_policy.allow_access_from_another_account]
}


resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]

    }


    actions = [
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.alb_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }
}

data "aws_caller_identity" "current" {}


resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = var.bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_alb_target_group" "alb_target_group" {
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    port                = 8080
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
}


resource "aws_lb_listener" "redirect_to_https" {
  load_balancer_arn = aws_alb.Gatus_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}



resource "aws_lb_listener" "forward_to_gatus_taget_group" {
  load_balancer_arn = aws_alb.Gatus_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb_target_group.arn
  }
}