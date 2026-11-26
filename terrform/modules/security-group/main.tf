resource "aws_security_group" "alb" {
  name        = var.sg
  description = "Allow traffic in from port 443 and 80 to alb"
  vpc_id      = var.vpc_id
  tags = {
    Name = "alb security group"
  }

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "ecs" {
  name        = var.sg_ecs
  description = "Allow traffic in from alb"
  vpc_id      = var.vpc_id
  tags = {
    Name = "ecs security group"
  }

  ingress {
    from_port       = 8080
    protocol        = "tcp"
    to_port         = 8080
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}