output "certificate" {
    value = { for cert in aws_acm_certificate.cert : cert.domain_name => cert.arn }
}