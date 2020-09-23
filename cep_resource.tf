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

  authorization        = "COGNITO_USER_POOLS"
  authorizer_id        = aws_api_gateway_authorizer.auth.id
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