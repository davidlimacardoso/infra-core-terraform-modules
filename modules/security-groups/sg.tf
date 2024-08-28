resource "aws_security_group" "create_sg" {
  for_each    = var.sg_ingress
  name        = each.key
  description = each.value.description
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      prefix_list_ids = lookup(ingress.value, "prefix_list_ids", null)
    }
  }

  egress {
    protocol    = "-1"
    from_port   = var.sg_egress.port
    to_port     = var.sg_egress.port
    cidr_blocks = var.sg_egress.cidr_blocks
  }

  tags = {
    Name = each.value.name
  }

  lifecycle {
    create_before_destroy = true
  }
}