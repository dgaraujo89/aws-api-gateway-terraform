
# Cognito user pool

resource "aws_cognito_user_pool" "pool" {
  name = var.pool_name
}

resource "aws_cognito_user_pool_domain" "domain" {
  domain       = var.domain_name
  user_pool_id = aws_cognito_user_pool.pool.id
}

resource "aws_cognito_resource_server" "resource" {
  identifier = "${var.domain_name}-server"
  name       = "${var.domain_name}-server"

  scope {
    scope_name        = "read"
    scope_description = "To read data"
  }

  user_pool_id = aws_cognito_user_pool.pool.id
}