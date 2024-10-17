resource "aws_lb" "ims_app" {
  name = "ims-app"
  load_balancer_type = "application"
  internal = false
  idle_timeout = 60
  enable_deletion_protection = false
  preserve_host_header = true

  subnets = [aws_subnet.public_0.id, aws_subnet.public_1.id]

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]
}

output "alb_dns_name" {
  value = aws_lb.ims_app.dns_name
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ims_app.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.ims_app.arn
      }
    }
  }
}

resource "aws_lb_target_group" "ims_app" {
  name = "ims-app"
  target_type = "ip"
  vpc_id = aws_vpc.ims_app.id
  port = 8080
  protocol = "HTTP"
  deregistration_delay = 300

  health_check {
    path = "/"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
    matcher = 200
    port = "traffic-port"
    protocol = "HTTP"
  }
  depends_on = [aws_lb.ims_app]
}

resource "aws_lb_listener_rule" "ims_app" {
  listener_arn      = aws_lb_listener.https.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ims_app.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}