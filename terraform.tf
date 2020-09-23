
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


# Cognito user pool

resource "aws_cognito_user_pool" "pool" {
  name = "cep-api-users"
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = "cep-api"
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_resource_server" "resource" {
  identifier = "cep-api"
  name       = "cep-api"

  scope {
    scope_name        = "read"
    scope_description = "To read data"
  }

  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_user_pool_client" "client" {
  name                          = "gwtclient"
  user_pool_id                  = aws_cognito_user_pool.pool.id
  supported_identity_providers  = ["COGNITO"]
  prevent_user_existence_errors = "ENABLED"

  generate_secret        = true
  refresh_token_validity = 30

  allowed_oauth_flows                  = ["client_credentials"]
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["cep-api/read"]

  depends_on = [
    aws_cognito_resource_server.resource
  ]
}


# Api Gateway

resource "aws_api_gateway_rest_api" "cep_root" {
  name        = "cep-api"
  description = "This is a proxy to viacep.com.br"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# cep endpoint

resource "aws_api_gateway_resource" "cep" {
  rest_api_id = aws_api_gateway_rest_api.cep_root.id
  parent_id   = aws_api_gateway_rest_api.cep_root.root_resource_id
  path_part   = "cep"
}

resource "aws_api_gateway_authorizer" "auth" {
  name          = "CepAuthorizer"
  rest_api_id   = aws_api_gateway_rest_api.cep_root.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.pool.arn]
}

resource "aws_api_gateway_resource" "cep_arg" {
  rest_api_id = aws_api_gateway_rest_api.cep_root.id
  parent_id   = aws_api_gateway_resource.cep.id
  path_part   = "{cep+}"

}

resource "aws_api_gateway_method" "cep" {
  rest_api_id = aws_api_gateway_rest_api.cep_root.id
  resource_id = aws_api_gateway_resource.cep_arg.id
  http_method = "GET"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.auth.id
  authorization_scopes = aws_cognito_user_pool_client.client.allowed_oauth_scopes

  request_parameters = {
    "method.request.path.cep" = true
  }
}

resource "aws_api_gateway_integration" "cep" {
  rest_api_id = aws_api_gateway_rest_api.cep_root.id
  resource_id = aws_api_gateway_resource.cep_arg.id
  http_method = aws_api_gateway_method.cep.http_method

  integration_http_method = aws_api_gateway_method.cep.http_method

  type = "HTTP_PROXY"
  uri  = "https://viacep.com.br/ws/{cep}/json"

  request_parameters = {
    "integration.request.path.cep" = "method.request.path.cep"
  }
}

# oauth token

resource "aws_api_gateway_resource" "token" {
  rest_api_id = aws_api_gateway_rest_api.cep_root.id
  parent_id   = aws_api_gateway_rest_api.cep_root.root_resource_id
  path_part   = "token"
}

resource "aws_api_gateway_method" "token" {
  rest_api_id = aws_api_gateway_rest_api.cep_root.id
  resource_id = aws_api_gateway_resource.token.id
  http_method = "POST"

  authorization = "NONE"
}

resource "aws_api_gateway_integration" "token" {
  rest_api_id = aws_api_gateway_rest_api.cep_root.id
  resource_id = aws_api_gateway_resource.token.id
  http_method = aws_api_gateway_method.token.http_method

  integration_http_method = aws_api_gateway_method.token.http_method

  type = "HTTP_PROXY"
  uri  = "https://${aws_cognito_user_pool_domain.domain.domain}.auth.${var.region}.amazoncognito.com/oauth2/token"
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

output "deploy_url" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}