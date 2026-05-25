# ============================================
# S3 BUCKET — stores your website files
# ============================================

resource "aws_s3_bucket" "website" {
  bucket = var.bucket_name

  tags = {
    Name        = var.project_name
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# Block ALL public access to the bucket
# CloudFront will access it privately instead
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning so you can recover old versions of files
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption on the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Enable access logging so you know who is accessing your bucket
resource "aws_s3_bucket_logging" "website" {
  bucket        = aws_s3_bucket.website.id
  target_bucket = aws_s3_bucket.website.id
  target_prefix = "access-logs/"
}

# Upload your website file to the bucket
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  source       = "../website/index.html"
  content_type = "text/html"
  etag         = filemd5("../website/index.html")
}

# ============================================
# CLOUDFRONT ORIGIN ACCESS CONTROL
# Allows CloudFront to privately access S3
# ============================================

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for ${var.project_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ============================================
# CLOUDFRONT DISTRIBUTION
# Delivers your website globally with HTTPS
# ============================================

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  default_root_object = "index.html"
  comment             = var.project_name
  price_class         = "PriceClass_100" # Only Europe and North America - cheapest option

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https" # Forces HTTP to redirect to HTTPS

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600  # Cache files for 1 hour
    max_ttl     = 86400 # Maximum cache of 24 hours
  }

  # Block access from countries with high fraud rates (optional security measure)
  restrictions {
    geo_restriction {
      restriction_type = "none" # No geo-restrictions for now
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true # Use CloudFront's free HTTPS certificate
  }

  tags = {
    Name      = var.project_name
    ManagedBy = "terraform"
  }
}

# ============================================
# S3 BUCKET POLICY
# Allows ONLY CloudFront to read from S3
# ============================================

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}