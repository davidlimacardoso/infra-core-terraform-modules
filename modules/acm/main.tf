resource "aws_acm_certificate" "cert" {
    for_each = { for cert in var.default: cert.name => cert }
  domain_name       = each.value.domain_name
  validation_method = "DNS"

  tags = {
    Name = each.value.name
  }
}