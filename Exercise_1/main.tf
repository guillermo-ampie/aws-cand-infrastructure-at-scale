# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  # The AWS profile defined for this project
  profile = "arch"

  region = local.region
}

locals {
  region   = "us-east-1"
  vpc_name = "dev-vpc"
  project  = "CAND Infrastucture at Scale"
  tier     = "dev"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"

  # set up vars
  name            = local.vpc_name
  cidr            = "10.1.0.0/16"
  azs             = ["${local.region}a", "${local.region}b"]
  private_subnets = ["10.1.10.0/24", "10.1.20.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.21.0/24"]
  enable_ipv6     = false

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_support   = true
  enable_dns_hostnames = true

  vpc_tags = {
    Name    = local.vpc_name
    Project = local.project
    Tier    = local.tier
  }

}
# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "Udacity_T2" {
  ami           = "ami-0742b4e673072066f"
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
  count         = 4
  tags = {
    Name    = "Udacity T2"
    Project = local.project
    Tier    = local.tier
  }
}

# TODO: provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "Udacity_M4" {
  ami           = "ami-0742b4e673072066f"
  instance_type = "m4.large"
  subnet_id     = module.vpc.public_subnets[1]
  count         = 2
  tags = {
    Name    = "Udacity M4"
    Project = local.project
    Tier    = local.tier
  }
}
