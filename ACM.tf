resource "aws_acm_certificate" "ims_app" {
  domain_name = aws_route53_record.ims_app.name
  subject_alternative_names = []
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "ims_app_certificate" {
  for_each = {
    for dvo in aws_acm_certificate.ims_app.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      type = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.ims_app.id
  name = each.value.name
  type = each.value.type
  records = [each.value.record]
  ttl = 60
}


resource "aws_acm_certificate_validation" "ims_app" {
  certificate_arn = aws_acm_certificate.ims_app.arn
  validation_record_fqdns = [
    for record in aws_route53_record.ims_app_certificate : record.fqdn
  ]
  depends_on = [aws_route53_record.ims_app_certificate]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.ims_app.arn
  port = "443"
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.ims_app.arn
  ssl_policy = "ELBSecurityPolicy-2016-08"

  depends_on = [aws_acm_certificate_validation.ims_app]

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.ims_app.arn
      }
    }

  }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.ims_app.arn
  port = "8080"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

