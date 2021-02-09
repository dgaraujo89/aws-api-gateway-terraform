
output "domain" {
  value = aws_cognito_user_pool_domain.domain.domain
}

output "arn" {
  value = aws_cognito_user_pool.pool.arn
}

output "scopes" {
  value = aws_cognito_user_pool_client.client.allowed_oauth_scopes
}