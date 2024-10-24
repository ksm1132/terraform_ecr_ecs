data "aws_route53_zone" "ims_app" {
  name = "tensaimaemukipositive.com"
}

resource "aws_route53_record" "ims_app" {
  name = data.aws_route53_zone.ims_app.name
  type = "A"
  zone_id = data.aws_route53_zone.ims_app.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_lb.ims_app.dns_name
    zone_id                = aws_lb.ims_app.zone_id
  }
}

output "domain_name" {
  value = aws_route53_record.ims_app.name
}