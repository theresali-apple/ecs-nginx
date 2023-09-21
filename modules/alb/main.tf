/*
data "aws_route53_zone" "selected" {
  zone_id = var.hosted_zone_id
}

resource "aws_acm_certificate" "alb_cert" {
  domain_name = data.aws_route53_zone.selected.name
  validation_method = "DNS"

  tags = {
    Project = "ecs-nginx"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
      for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
        name = dvo.resource_record_name
        record = dvo.resource_record_value
        type = dvo.resource_record_type
      }
    }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

resource "aws_acm_certificate_validation" "alb_cert" {
  certificate_arn = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
*/

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [
    var.load_balancer_sg.id]
  subnets            = [
    var.load_balancer_subnet_a.id,
    var.load_balancer_subnet_b.id,]

  tags = {
    Project = "ecs-nginx"
  }
}

resource "aws_lb_target_group" "ecs" {
  name     = "ecs"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 300
    path                = "/"
    timeout             = 60
    matcher             = "200"
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  tags = {
    Project = "ecs-nginx"
  }
}

/*
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = aws_acm_certificate_validation.alb_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}
*/

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"
/*
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
*/
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

locals {
  alb_origin_id = "my-alb"
}


resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = aws_lb.my_alb.dns_name
    origin_id   = aws_lb.my_alb.dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "My CloudFront distribution"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_lb.my_alb.dns_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    #acm_certificate_arn      = aws_acm_certificate.alb_cert.arn
    #ssl_support_method       = "sni-only"
    #minimum_protocol_version = "TLSv1.2_2018"
  }

}