# List available zones
data "aws_availability_zones" "aws_az" {
  state = "available"
}

resource "aws_subnet" "create_subnet_public" {
  for_each          = local.public_subnets
  vpc_id            = aws_vpc.aws-vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name       = each.value.name
    tag        = each.value.tag
    short_name = each.value.tag
  }
}

resource "aws_subnet" "create_subnet_private" {
  for_each          = local.private_subnets
  vpc_id            = aws_vpc.aws-vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az
  tags = {
    Name                  = each.value.name
    tag                   = each.value.tag
    short_name            = each.value.tag
    terraform_environment = each.value.terraform_environment
  }
}

resource "aws_route_table_association" "private" {
  for_each       = local.private_subnets
  subnet_id      = aws_subnet.create_subnet_private[each.key].id
  route_table_id = var.single_nat ? aws_route_table.aws-private-route-table[0].id : aws_route_table.aws-private-route-table[each.value.index].id
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = aws_subnet.create_subnet_public[each.key].id
  route_table_id = aws_route_table.aws-public-route-table.id
}

