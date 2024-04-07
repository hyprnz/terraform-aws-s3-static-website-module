provider "aws" {
  alias  = "global"
  region = "us-east-1"
}

locals {
  create_custom_route53_record = local.enable_custom_domain_name && var.create_custom_route53_record
}

resource "aws_route53_record" "website" {
  count = local.create_custom_route53_record ? 1 : 0

  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "this" {
  count = local.create_certificate ? 1 : 0

  provider = aws.global

  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = var.module_tags

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  domain_validation_options = local.create_certificate ? aws_acm_certificate.this[0].domain_validation_options : []
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in local.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = var.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "this" {
  count = local.create_certificate ? 1 : 0

  provider = aws.global

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}