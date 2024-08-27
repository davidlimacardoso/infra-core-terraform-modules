output "private_subnet_ids" {
  value       = [for subnet in aws_subnet.create_subnet_private : subnet.id]
  description = "List of private subnet IDs"
}

output "public_subnet_ids" {
  value       = [for subnet in aws_subnet.create_subnet_public : subnet.id]
  description = "List of public subnet IDs"
}

output "vpc_id" {
  value       = aws_vpc.aws-vpc.id
  description = "VPC ID"
}

output "vpc_cidr_block" {
  value       = aws_vpc.aws-vpc.cidr_block
  description = "VPC CIDR block"
}

output "private_subnet_ids_per_environment" {
  value       = { for x in distinct(values(aws_subnet.create_subnet_private).*.tags.terraform_environment) : x => { for i in aws_subnet.create_subnet_private : i.tags["tag"] => i.id... if i.tags["terraform_environment"] == "${x}" } }
  description = "List of private subnet IDs per environment"
}

output "private_subnet_ids_per_tag" {
  value       = { for subnet in aws_subnet.create_subnet_private : subnet.tags["tag"] => subnet.id... }
  description = "List of private subnet IDs per tag"
}

output "public_subnet_ids_per_tag" {
  value       = { for subnet in aws_subnet.create_subnet_public : subnet.tags["tag"] => subnet.id... }
  description = "List of public subnet IDs per tag"
}

output "nat_gateway" {
  value       = [for nat in aws_nat_gateway.gw : { public_ip = nat.public_ip, name = nat.tags["Name"], nat_id = nat.id }]
  description = "List of NAT gateways"
}

output "private_route_table_id" {
  value       = [for rt in aws_route_table.aws-private-route-table : { id = rt.id, name = rt.tags["Name"] }]
  description = "List of private route table IDs"
}