module "static_website_example" {
  source = "../../"

  providers = {
    aws = aws
  }

  site_name = "frontend"
  namespace = var.namespace

  domain_name                  = var.domain_name
  certificate_arn              = var.certificate_arn
  create_certificate           = var.create_certificate
  zone_id                      = var.zone_id
  create_custom_route53_record = var.create_custom_route53_record

  site_config_values = {
    "auth_url"    = "www.google.com"
    "backend_url" = "www.aws.com"
    "version"     = "1.1.0"
  }

  cloudfront_custom_errors = [
    {
      error_caching_min_ttl = 300
      error_code            = 404
      response_code         = 200
      response_page_path    = "/index.html"
  }]

  module_tags     = { "Environment" = "test", "env" = "test" }
  s3_tags         = { "s3-example" = "true" }
  cloudfront_tags = { "cloudfront-example" = "true" }

  comment = "Example static website cloudfront distribution"
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" { default = "us-west-2" }
variable "domain_name" { default = null }
variable "zone_id" { default = "" }
variable "create_custom_route53_record" { default = false }
variable "certificate_arn" { default = "" }
variable "namespace" {}
variable "create_certificate" { default = true }
