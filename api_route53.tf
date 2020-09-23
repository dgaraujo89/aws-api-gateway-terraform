
data "aws_route53_zone" "zone" {
  name = var.domain_name
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "api"
  type    = "A"

  alias {
    evaluate_target_health = true
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
  }

  depends_on = [
    aws_api_gateway_rest_api.cep_root
  ]
}