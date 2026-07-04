# DNS for var.domain_name lives at Spaceship, not Route 53, so validation
# records can't be created automatically here — see the
# certificate_validation_records output for what to add manually.
resource "aws_acm_certificate" "site" {
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# The CNAME records from certificate_validation_records have been added at
# Spaceship and the certificate is confirmed ISSUED, so this now completes
# immediately instead of polling.
resource "aws_acm_certificate_validation" "site" {
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for o in aws_acm_certificate.site.domain_validation_options : o.resource_record_name]
}
