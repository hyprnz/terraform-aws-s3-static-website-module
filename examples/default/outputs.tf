output "bucket_domain" {
  value = module.static_website_example.s3_bucket_domain_name
}

output "bucket_regional_domain" {
  value = module.static_website_example.s3_bucket_regional_domain_name
}

output "cloudfront_url" {
  value = module.static_website_example.cloudfront_url
}

output "cloudfront_hosted_zone" {
  value = module.static_website_example.cloudfront_hosted_zone
}

output "domain_name" {
  value = var.domain_name
}