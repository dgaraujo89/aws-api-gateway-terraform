
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