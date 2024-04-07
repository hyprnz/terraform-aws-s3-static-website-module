output "custom_domain_name" {
  description = "The custom domain name of the CloudFront distribution."
  value       = var.domain_name
}

output "s3_bucket_domain_name" {
  description = "The domain name of the s3 web site bucket."
  value       = aws_s3_bucket.origin.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the s3 web site bucket."
  value       = aws_s3_bucket.origin.bucket_regional_domain_name
}

output "cloudfront_url" {
  description = "The URL for the Cloudfront Distribution - used to set the alias for the custom domain."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_hosted_zone" {
  description = "The hosted zone id of the Cloudfront Distribution"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}
