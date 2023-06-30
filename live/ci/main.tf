# live/ci/main.tf
module "vpc" {
  source  = "../../modules/vpc"
  cidr    = "10.36.0.0/19"
  tenancy = "default"
  name    = "vpc-nonprod-app-ew2-ci"
}

module "subnet1" {
  source     = "../../modules/subnet"
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.36.0.0/24" # Define appropriate CIDR blocks for each subnet
  az         = "eu-west-2a"
  name       = "subnet-nonprod-app-ew2-app-ew2a"
}

# Repeat module "subnet" block for each subnet...
module "route_table" {
  source = "../../modules/route_table"
  vpc_id = module.vpc.vpc_id
  name   = "rtb-nonprod-sec-ew2-ci"
}

module "transit_gateway_attachment" {
  source             = "../../modules/transit_gateway_attachment"
  transit_gateway_id = "tgw-0faffe01812d48d37"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = [module.subnet1.subnet_id] # Include all your subnet module IDs here
}

module "default_route" {
  source             = "../../modules/default_route"
  route_table_id     = module.route_table.route_table_id
  transit_gateway_id = "tgw-0faffe01812d48d37"
}

module "security_group" {
  source = "../../modules/security_group"
  vpc_id = module.vpc.vpc_id
  name   = "sg-nonprod-app-ew2-ci"
}
