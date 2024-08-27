# Create Internet Gateway
resource "aws_internet_gateway" "aws-igw" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name = var.igw_name
  }
}