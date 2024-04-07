locals {
  bucket_name         = format("%s.%s", var.site_name, var.namespace)
  logging_bucket_name = format("%s-%s.%s", var.site_name, "site-logs", var.namespace)
  tags                = merge({ "Site Name" = var.site_name }, var.module_tags)

  enable_custom_domain_name = try(length(var.domain_name) > 0, false)
  create_certificate        = local.enable_custom_domain_name && var.create_certificate
}

resource "aws_s3_bucket" "origin" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = merge(local.tags, var.s3_tags)
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.origin.id
  policy = data.aws_iam_policy_document.allow_cloudfront.json
}

resource "aws_s3_bucket" "log" {
  bucket = local.logging_bucket_name

  tags = merge(local.tags, var.s3_tags)
}

resource "aws_s3_bucket_ownership_controls" "log" {
  bucket = aws_s3_bucket.log.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "log" {
  bucket = aws_s3_bucket.log.id
  acl    = "log-delivery-write"

  depends_on = [aws_s3_bucket_ownership_controls.log]
}

resource "aws_s3_object" "config_file" {
  key     = "config.json"
  bucket  = aws_s3_bucket.origin.id
  content = jsonencode(var.site_config_values)

  tags = local.tags
}
