# Seach transit gateway by tag name
data "aws_ec2_transit_gateway" "get_id" {
  count = length(var.transit_gateway_name) > 0 ? 1 : 0
  filter {
    name   = "tag:Name"
    values = [var.transit_gateway_name]
  }
}

#Creating Public Route Table
resource "aws_route_table" "aws-public-route-table" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name = "${var.vpc_name}-rtb-public"
  }
}

# Route to internet gateway for public subnets
resource "aws_route" "pub" {
  count                  = length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.aws-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.aws-igw[count.index].id
}

# If the single_nat is true, create a single route table for private subnets, otherwise, create one route table per max amount of privates subnets
# The route is not created here because it conflicts with the aws_route that the tgw will manage
resource "aws_route_table" "aws-private-route-table" {
  count  = var.single_nat ? 1 : max(values(local.private_subnets).*.index...) + 1
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name = "${var.vpc_name}-rtb-private-${data.aws_availability_zones.aws_az.names[count.index]}"
  }
}

# When exists infracore subnet, create a route to nat gateway with the same amount of subnets that it has, otherwise, don't create
resource "aws_route" "priv" {
  count                  = length(try(local.check_public_subnets["infra"].cidr, local.check_public_subnets)) > 0 ? local.number_of_private_routes : 0
  route_table_id         = aws_route_table.aws-private-route-table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = length(data.aws_ec2_transit_gateway.get_id) > 0 ? null : aws_nat_gateway.gw[count.index].id
  transit_gateway_id     = length(data.aws_ec2_transit_gateway.get_id) > 0 ? data.aws_ec2_transit_gateway.get_id[0].id : null
}