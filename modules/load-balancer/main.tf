resource "aws_lb_target_group" "create_lb_tg" {
  for_each = { for alb in var.alb : alb.name => alb }
  name     = "${each.value.name}-lb-tg"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = each.value.vpc_id

  health_check {
    port                = each.value.health_port
    protocol            = each.value.protocol
    interval            = 30
    path                = each.value.health_path
    unhealthy_threshold = each.value.health_threashold
    healthy_threshold   = each.value.health_threashold
  }
}

resource "aws_lb_target_group_attachment" "create_tg_att" {
  for_each         = { for alb in var.alb : alb.name => alb }
  target_group_arn = aws_lb_target_group.create_lb_tg[each.key].arn
  target_id        = each.value.instance_id
  port             = each.value.port
}

resource "aws_lb" "create_lb" {
  for_each           = { for alb in var.alb : alb.name => alb }
  name               = "${each.value.name}-${var.env}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = each.value.lb_security_group
  subnets            = each.value.subnets

  enable_deletion_protection = false
}

resource "aws_lb_listener" "https" {
  for_each          = { for alb in var.alb : alb.name => alb }
  load_balancer_arn = aws_lb.create_lb[each.key].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = each.value.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.create_lb_tg[each.key].arn
  }
}

resource "aws_lb_listener" "http" {
  for_each          = { for alb in var.alb : alb.name => alb }
  load_balancer_arn = aws_lb.create_lb[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.create_lb_tg[each.key].arn
  }
}