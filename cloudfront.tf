# Create the CloudFront distribution
resource "aws_cloudfront_distribution" "website_cdn" {
  depends_on = [
    aws_s3_bucket_website_configuration.site_website_config,
    aws_s3_bucket_policy.site_bucket_policy
  ]
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for my-public-website-bucket"
  default_root_object = "index.html"
  origin {
    domain_name = aws_s3_bucket_website_configuration.site_website_config.website_endpoint
    origin_id   = "s3-website-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-website-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
output "cloudfront_cdn_url" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.website_cdn.domain_name
}