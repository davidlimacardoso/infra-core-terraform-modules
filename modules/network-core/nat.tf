# Dinamic Nat Gateway
# This receive for default publics network of infra group (var.public_subnets.infra.cidr_blocks) an create a Nat Gateway for each then
resource "aws_nat_gateway" "gw" {
  count         = var.single_nat && length(local.public_subnets) > 0 ? 1 : length(local.check_public_subnets.infra.cidr)
  subnet_id     = local.subnet_public_infra[count.index].id
  allocation_id = aws_eip.gw[count.index].id

  tags = {
    Name = "${var.nat_gateway}-${data.aws_availability_zones.aws_az.names[count.index]}"
  }

  depends_on = [
    aws_subnet.create_subnet_public
  ]
}
