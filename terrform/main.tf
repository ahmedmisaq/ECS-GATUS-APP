module "networking" {
  source              = "./modules/networking"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_ids = var.private_subnet_ids
}


module "ecr" {
  source = "./modules/ecr"
  ecr    = var.ecr
}


module "sg" {
  source = "./modules/security-group"
  sg     = var.sg
  sg_ecs = var.sg_ecs
  vpc_id = module.networking.Gatus_VPC_id
}

module "alb" {
  source             = "./modules/load-balacing"
  s3_alb             = var.s3_alb
  alb                = var.alb
  sg                 = module.sg.Gatus_Security_Group_Id
  public_subnet_cidr = module.networking.Public_subnet_ids
  vpc_id             = module.networking.Gatus_VPC_id
  certificate_arn    = module.dns.certificate_arn
}

data "aws_caller_identity" "current" {}

module "dns" {
  source      = "./modules/dns"
  domain_name = var.domain_name
}

module "ecs" {
  source = "./modules/ecs"
  ecr_url = module.ecr.ecr_url
  iam_role_arn = module.IAM.iam_role_arn
  sg_ecs = module.sg.Gatus_Security_Group_ecs_id
  private_subnet_ids = module.networking.Private_subnet_ids
  target_group_arn = module.alb.alb_target_group_arn
  ecr_sha = var.ecr_sha
}

module "IAM" {
  source = "./modules/IAM"
  iam_role_arn = module.IAM.iam_role_arn
  sg_ecs = module.sg.Gatus_Security_Group_ecs_id
  private_subnet_ids = var.private_subnet_ids
}