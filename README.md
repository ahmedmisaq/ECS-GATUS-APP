# ec2_project_gatus
ECS Project - Build, containerise and deploy an application using Docker, Terraform, and ECS, with HTTPS and a custom domain

Gatus is a developer-oriented health dashboard that gives you the ability to monitor your services using HTTP, ICMP, TCP, and even DNS queries as well as evaluate the result of said queries by using a list of conditions on values like the status code, the response time, the certificate expiration, the body and many others. The icing on top is that each of these health checks can be paired with alerting via Slack, Teams, PagerDuty, Discord, Twilio and many more.















Terraform State

1. resource "aws_s3_bucket" "state"

This block creates the physical S3 bucket in your AWS account.
• bucket = "gatus-backend-ecs2": This specifies the globally unique name of your bucket.
• "state": This is the local Terraform name (or alias) used to reference this specific bucket elsewhere in your code.

2. resource "aws_s3_bucket_versioning" "state"

This block attaches a versioning configuration to the bucket you just created.
• bucket = aws_s3_bucket.state.id: This creates a dependency. It tells Terraform to take the ID of the bucket created in the first block and apply this versioning policy to it.
• status = "Enabled": This turns on versioning. Every time a file (like a Terraform state file) is updated or deleted, AWS will save the older version instead of overwriting it permanently. This is a best practice for protecting your data against accidental deletion or corruption.





/* Gatus Project VPC
resource "aws_vpc" "Gatus_VPC" {
  cidr_block = "10.0.0.0/22"
  tags = {
    Name = "Gatus_VPC"
}

# Gatus Public Subnet 1
resource "aws_subnet" "Public_Subnet1" {
  vpc_id     = aws_vpc.Gatus_VPC.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "Public_Subnet1"
  }
}

resource "aws_subnet" "Public_Subnet2" {
  vpc_id     = aws_vpc.Gatus_VPC.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "Public_Subnet2"
  }
}

resource "aws_subnet" "Private_Subnet1" {
  vpc_id     = aws_vpc.Gatus_VPC.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "Private_Subnet1"
  }
}

resource "aws_subnet" "Private_Subnet2" {
  vpc_id     = aws_vpc.Gatus_VPC.id
  cidr_block = "10.0.4.0/24"
  tags = {
    Name = "Private_Subnet2"
  }
}