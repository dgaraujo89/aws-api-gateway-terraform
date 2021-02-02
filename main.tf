
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = var.profile
  region  = var.region
}


# Api Gateway

resource "aws_api_gateway_rest_api" "cep_root" {
  name        = "cep-api"
  description = "This is a proxy to viacep.com.br"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API deployment to test environment

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.cep,
    aws_api_gateway_integration.token
  ]

  rest_api_id       = aws_api_gateway_rest_api.cep_root.id
  stage_name        = "test"
  stage_description = "Teste environment"
}

# domain

resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "api.${var.domain_name}"
  regional_certificate_arn = aws_acm_certificate.cert.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [
    aws_acm_certificate.cert
  ]
}

resource "aws_api_gateway_base_path_mapping" "test" {
  api_id      = aws_api_gateway_rest_api.cep_root.id
  stage_name  = aws_api_gateway_deployment.deployment.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
  base_path   = "test"
}

