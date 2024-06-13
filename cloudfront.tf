locals {
  acm_certificate_arn = local.create_certificate ? aws_acm_certificate.this[0].arn : var.certificate_arn
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    origin_id                = aws_s3_bucket.origin.id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    domain_name              = aws_s3_bucket.origin.bucket_regional_domain_name
  }

  aliases     = local.enable_custom_domain_name ? [var.domain_name] : null
  enabled     = true
  comment     = var.comment
  price_class = var.price_class

  default_root_object = var.index_document_default
  wait_for_deployment = var.wait_for_deployment

  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_errors
    content {
      error_caching_min_ttl = custom_error_response.value["error_caching_min_ttl"]
      error_code            = custom_error_response.value["error_code"]
      response_code         = custom_error_response.value["response_code"]
      response_page_path    = custom_error_response.value["response_page_path"]
    }
  }

  default_cache_behavior {
    allowed_methods  = var.cloudfront_allowed_methods
    cached_methods   = var.cloudfront_cached_methods
    target_origin_id = aws_s3_bucket.origin.id
    compress         = var.enable_cdn_compression

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    path_pattern           = var.index_document_default
    smooth_streaming       = false
    target_origin_id       = aws_s3_bucket.origin.id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    path_pattern           = "config.json"
    smooth_streaming       = false
    target_origin_id       = aws_s3_bucket.origin.id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    # Certificates for cloudfront _must_ be created in us-east-1
    cloudfront_default_certificate = !local.enable_custom_domain_name
    acm_certificate_arn            = local.enable_custom_domain_name ? local.acm_certificate_arn : null
    ssl_support_method             = local.enable_custom_domain_name ? "sni-only" : null
    minimum_protocol_version       = local.enable_custom_domain_name ? "TLSv1.2_2021" : null
  }

  logging_config {
    bucket = aws_s3_bucket.log.bucket_domain_name
    prefix = "cloudfront/"
  }

  tags = merge(local.tags, var.cloudfront_tags)

  depends_on = [aws_s3_bucket_acl.log]
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = aws_s3_bucket.origin.id
  description                       = "S3 Bucket accsss policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
