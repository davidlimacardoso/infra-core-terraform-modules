output "domain_name" {
  value = { for alb in var.alb : alb.name => aws_lb.create_lb[alb.name].dns_name }
}