
# Cloudlaunch-site-bucket (Public)
resource "aws_s3_bucket" "site_bucket" {
  bucket = "cloudlaunch-site-bucket-roslaan-001"
}

resource "aws_s3_bucket_website_configuration" "site_website_config" {
  bucket = aws_s3_bucket.site_bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "site_bucket_public_access" {
  bucket                  = aws_s3_bucket.site_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "site_bucket_policy" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.site_bucket.arn}/*"
      }
    ]
  })
}

# Cloudlaunch-private-bucket (Private)
resource "aws_s3_bucket" "private_bucket" {
  bucket = "cloudlaunch-private-bucket-roslaan-001"
}

resource "aws_s3_bucket_public_access_block" "private_bucket_public_access" {
  bucket                  = aws_s3_bucket.private_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Cloudlaunch-visible-only-bucket (Private)
resource "aws_s3_bucket" "visible_only_bucket" {
  bucket = "cloudlaunch-visible-only-bucket-roslaan-001"
}

resource "aws_s3_bucket_public_access_block" "visible_only_bucket_public_access" {
  bucket                  = aws_s3_bucket.visible_only_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload files to the public site bucket
resource "aws_s3_object" "site_files" {
  for_each = fileset("./website", "**")
  bucket   = aws_s3_bucket.site_bucket.id
  key      = each.value
  source   = "./website/${each.value}"
  etag     = filemd5("./website/${each.value}")
  content_type = lookup({
    "html" = "text/html",
    "css"  = "text/css",
    "js"   = "application/javascript",
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

output "site_bucket_link" {
  value = aws_s3_bucket_website_configuration.site_website_config.website_endpoint
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.website_cdn.domain_name
}