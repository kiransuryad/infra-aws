locals {
  subnets = {
    "sub-nonprod-app-ew2-ci-app-ew2a"   = { cidr = "10.36.0.0/21", az = "eu-west-2a" },
    "sub-nonprod-app-ew2-ci-api-ew2a"   = { cidr = "10.36.18.0/26", az = "eu-west-2a" },
    "sub-nonprod-app-ew2-ci-data-ew2a"  = { cidr = "10.36.16.0/24", az = "eu-west-2a" },
    "sub-nonprod-app-ew2-ci-tools-ew2a" = { cidr = "10.36.19.0/26", az = "eu-west-2a" },
    "sub-nonprod-app-ew2-ci-msk-ew2a"   = { cidr = "10.36.20.0/28", az = "eu-west-2a" },
    "sub-nonprod-app-ew2-ci-infra-ew2a" = { cidr = "10.36.21.0/24", az = "eu-west-2a" },
    "sub-nonprod-app-ew2-ci-tgw-ew2a"   = { cidr = "10.36.31.0/28", az = "eu-west-2a" },
    "sub-nonprod-app-ew2-ci-app-ew2b"   = { cidr = "10.36.8.0/21", az = "eu-west-2b" },
    "sub-nonprod-app-ew2-ci-api-ew2b"   = { cidr = "10.36.18.128/26", az = "eu-west-2b" },
    "sub-nonprod-app-ew2-ci-data-ew2b"  = { cidr = "10.36.17.0/24", az = "eu-west-2b" },
    "sub-nonprod-app-ew2-ci-tools-ew2b" = { cidr = "10.36.19.128/26", az = "eu-west-2b" },
    "sub-nonprod-app-ew2-ci-msk-ew2b"   = { cidr = "10.36.20.128/28", az = "eu-west-2b" },
    "sub-nonprod-app-ew2-ci-infra-ew2b" = { cidr = "10.36.22.0/24", az = "eu-west-2b" },
    "sub-nonprod-app-ew2-ci-tgw-ew2b"   = { cidr = "10.36.31.128/28", az = "eu-west-2b" }
  }

  endpoints = {
    ec2 = {
      service_name = "com.amazonaws.eu-west-2.ec2"
      name         = "vpce-nonprod-sec-ew2-ci-ec2"
    },
    ec2messages = {
      service_name = "com.amazonaws.eu-west-2.ec2messages"
      name         = "vpce-nonprod-sec-ew2-ci-ec2messages"
    },
    ssm = {
      service_name = "com.amazonaws.eu-west-2.ssm"
      name         = "vpce-nonprod-sec-ew2-ci-ssm"
    },
    ssmmessages = {
      service_name = "com.amazonaws.eu-west-2.ssmmessages"
      name         = "vpce-nonprod-sec-ew2-ci-ssmmessages"
    }
  }
}

module "vpc" {
  source  = "../../modules/networking/vpc"
  cidr    = "10.36.0.0/19"
  tenancy = "default"
  name    = "vpc-nonprod-app-ew2-ci"
  region  = "eu-west-2" # replace with your region
}

module "subnets" {
  source   = "../../modules/networking/subnet"
  for_each = local.subnets

  vpc_id     = module.vpc.vpc_id
  cidr_block = each.value.cidr
  az         = each.value.az
  name       = each.key
}


module "route_table" {
  source = "../../modules/networking/route_table"
  vpc_id = module.vpc.vpc_id
  name   = "rtb-nonprod-sec-ew2-ci"
  region = "eu-west-2" # replace with your region
}



module "transit_gateway_attachment" {
  source             = "../../modules/networking/transit_gateway_attachment"
  transit_gateway_id = "tgw-0faffe01812d48d37"
  vpc_id             = module.vpc.vpc_id
  name               = "tgw-attach-nonprod-sec-ew2-ci"
  subnet_ids = [
    module.subnets["sub-nonprod-app-ew2-ci-tgw-ew2a"].subnet_id,
    module.subnets["sub-nonprod-app-ew2-ci-tgw-ew2b"].subnet_id
  ]
}



module "default_route" {
  source             = "../../modules/networking/default_route"
  route_table_id     = module.route_table.route_table_id
  transit_gateway_id = "tgw-0faffe01812d48d37"
  region             = "eu-west-2" # replace with your region
}

module "security_group" {
  source = "../../modules/security/security_group"
  vpc_id = module.vpc.vpc_id
  name   = "security-group-vpc-nonprod-sec-ew2-ci-vpce"
}

module "vpc_endpoint" {
  for_each = local.endpoints

  source            = "../../modules/networking/vpc_endpoint"
  vpc_id            = module.vpc.vpc_id
  service_name      = each.value.service_name
  subnet_ids        = [module.subnets["sub-nonprod-app-ew2-ci-infra-ew2a"].subnet_id, module.subnets["sub-nonprod-app-ew2-ci-infra-ew2b"].subnet_id]
  security_group_id = module.security_group.security_group_id
  name              = each.value.name
}
