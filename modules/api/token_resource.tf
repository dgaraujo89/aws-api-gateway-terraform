# oauth token endpoint

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
  uri  = "https://${var.user_pool.domain}.auth.${var.region}.amazoncognito.com/oauth2/token"
}