resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  origin {
    domain_name = var.s3_bucket_origin
    origin_id   = "${var.name}-s3-origin"
    s3_origin_config {
      origin_access_identity = ""
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "${var.name}-s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  viewer_certificate {
    acm_certificate_arn         = var.acm_cert_arn != "" ? var.acm_cert_arn : null
    ssl_support_method          = var.acm_cert_arn != "" ? "sni-only" : null
    cloudfront_default_certificate = var.acm_cert_arn == "" ? true : false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = { Name = "${var.name}-cdn" }
}

 
