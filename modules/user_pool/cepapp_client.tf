
resource "aws_cognito_user_pool_client" "client" {
  name                          = "cepapp"
  user_pool_id                  = aws_cognito_user_pool.pool.id
  supported_identity_providers  = ["COGNITO"]
  prevent_user_existence_errors = "ENABLED"

  generate_secret        = true
  refresh_token_validity = 30

  allowed_oauth_flows                  = ["client_credentials"]
  explicit_auth_flows                  = ["ALLOW_REFRESH_TOKEN_AUTH"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["${aws_cognito_resource_server.resource.name}/read"]

  depends_on = [
    aws_cognito_resource_server.resource
  ]
}