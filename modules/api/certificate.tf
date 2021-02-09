
resource "aws_acm_certificate" "cert" {
  certificate_body = file(var.certificate)
  private_key      = file(var.private_key)

  lifecycle {
    create_before_destroy = true
  }
}