
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket  = "<bucket name>"
    key     = "api/cep/tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}

module "user_pool" {
  source = "./modules/user_pool"

  domain_name = "cep-api"
  pool_name   = "cep-api-users"
}

module "api" {
  source = "./modules/api"

  domain_name = var.domain_name
  region      = var.region

  certificate = var.certificate
  private_key = var.private_key

  user_pool = {
    domain = module.user_pool.domain
    arn    = module.user_pool.arn
    scopes = module.user_pool.scopes
  }

  depends_on = [
    module.user_pool
  ]
}