resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]

  tags = {
    Name    = "github-actions-oidc"
    Purpose = "CI/CD pipeline authentication"
  }
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions_role" {

  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = var.allowed_subjects
          }
        }
    }]
  })
}

resource "aws_iam_policy" "github_policy" {
  name        = "Github_ECR_Push"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Effect   = "Allow"
        Resource = data.aws_ecr_repository.Gatus_ECR.arn
      },
      {
        "Effect" : "Allow",
        "Action" : "ecr:GetAuthorizationToken",
        "Resource" : "*"
      }
    ]
  })
}

data "aws_ecr_repository" "Gatus_ECR" {
  name = "gatus-terraform-ecr"
}


resource "aws_iam_role_policy_attachment" "github_policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_policy.arn

}

resource "aws_iam_role_policy_attachment" "S3_Access_Policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_s3_policy.arn
}

resource "aws_iam_policy" "github_s3_policy" {
  name        = "S3_Access_Policy"
  path        = "/"
  description = "My S3 policy"
  policy      = data.aws_iam_policy_document.github_actions_s3_access.json
}


data "aws_iam_policy_document" "github_actions_s3_access" {
  statement {

    actions = [
      "s3:ListBucket",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketLocation",
    ]
    resources = [
      data.aws_s3_bucket.tf_remote_state.arn,
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${data.aws_s3_bucket.tf_remote_state.arn}/ECS_GATUS/terraform/terraform.tfstate"
    ]
  }

  statement {

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "S3:GetBucketEncryption",
      "s3:GetEncryptionConfiguration"
    ]

    resources = [
      "${data.aws_s3_bucket.tf_remote_state.arn}/ECS_GATUS/terraform/terraform.tfstate.tflock"
    ]
  }
}

data "aws_s3_bucket" "tf_remote_state" {
  bucket = "gatus-remote-state432102"
}







# Route table permission


resource "aws_iam_policy" "github_route_table_policy" {
  name        = "Route_table_Access_Policy"
  path        = "/"
  description = "My Route table_Access policy"
  policy      = data.aws_iam_policy_document.github_actions_route_table_access.json
}


data "aws_iam_policy_document" "github_actions_route_table_access" {
  statement {

    actions = [
      "ec2:DescribeRouteTables",
    ]
   resources = ["*"]
  }

    statement {
    sid    = "EC2ReadAccess"
    effect = "Allow"

    actions = [
      "ec2:DescribeRouteTables",
      "ec2:DescribeAddresses",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNatGateways",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeAddressesAttribute"
    ]

    resources = ["*"]
  }

    statement {
      sid = "IAMReadAccess"
      effect = "Allow"

    actions = [
        "iam:Generate*",
        "iam:Get*",
        "iam:List*",
        "s3:GetBucketPolicy",
        "ecr:DescribeRepositories",
        "acm:DescribeCertificate",
        "ecs:DescribeClusters", 
        "s3:GetEncryptionConfiguration",
        "ec2:DescribeVpcAttribute",
        "EC2: DescribeAvailabilityZones",
        "acm:ListTagsForCertificate",
        "ecr:ListTagsForResource"

    ]
  resources = ["*"]
    }
}

resource "aws_iam_role_policy_attachment" "Route_table_Access_Policy_attachment" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_route_table_policy.arn
}