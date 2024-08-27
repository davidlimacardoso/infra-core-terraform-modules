# Create a elastic IP for each range of var.network_core.subnets.public.infra
resource "aws_eip" "gw" {
  count  = var.single_nat && length(var.public_subnets) > 0 ? 1 : length(try(local.check_public_subnets["infra"].cidr, local.check_public_subnets))
  domain = "vpc"

  tags = {
    Name = "${var.elastic_ip}-${data.aws_availability_zones.aws_az.names[count.index]}"
  }
}