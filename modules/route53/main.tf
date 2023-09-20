data "aws_route53_zone" "selected" {
  zone_id  = var.hosted_zone_id
}

resource "aws_route53_record" "site_domain" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = data.aws_route53_zone.selected.name
  type    = "A"

  alias {
    name                   = var.alb.dns_name
    zone_id                = var.alb.zone_id
    evaluate_target_health = true
  }
}
