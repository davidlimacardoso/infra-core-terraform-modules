variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
}

variable "igw_name" {
  type        = string
  default     = null
  description = "The name of the Internet Gateway"
}

variable "nat_gateway" {
  type        = string
  default     = null
  description = "The name of the NAT Gateway"
}

variable "elastic_ip" {
  type        = string
  default     = null
  description = "The name of the Elastic IP"
}

variable "single_nat" {
  type        = bool
  default     = true
  description = "Whether to use a single NAT Gateway or not"
}

variable "private_subnets" {
  type = list(object({
    name        = string
    cidr_blocks = list(string)
    tag         = string
  }))
  description = "The list of private subnet CIDR blocks"
}

variable "public_subnets" {
  type = list(object({
    name        = string
    cidr_blocks = list(string)
    tag         = string
  }))
  description = "The list of private subnet CIDR blocks"
  default     = []
}

variable "transit_gateway_name" {
  type        = string
  default     = ""
  description = "The name of the Transit Gateway"
}

locals {

  subnet_details_infra = {
    for subnet in aws_subnet.create_subnet_public : subnet.availability_zone =>
    {
      cidr_block        = subnet.cidr_block,
      id                = subnet.id,
      tags              = subnet.tags
      availability_zone = subnet.availability_zone
      index             = subnet.tags.tag
    }
    if subnet.tags.tag == "infra"
  }

  subnet_public_infra = values(local.subnet_details_infra)

  transformed_private_subnets = flatten([
    for subnet in var.private_subnets :
    [
      for index, cidr in subnet.cidr_blocks :
      {
        name                  = "${subnet.name}-${data.aws_availability_zones.aws_az.names[index]}"
        cidr_block            = "${cidr}",
        tag                   = "${subnet.tag}",
        index                 = "${index}",
        az                    = data.aws_availability_zones.aws_az.names[index]
        terraform_environment = try("${subnet.terraform_environment}", "all")
      }
    ]
  ])

  transformed_public_subnets = length(var.public_subnets) > 0 ? flatten([
    for subnet in var.public_subnets :
    [
      for index, cidr in subnet.cidr_blocks :
      {
        name       = "${subnet.name}-${data.aws_availability_zones.aws_az.names[index]}"
        cidr_block = "${cidr}",
        tag        = "${subnet.tag}",
        index      = "${index}",
        az         = data.aws_availability_zones.aws_az.names[index]
      }
    ]
  ]) : []

  private_subnets = { for subnet in local.transformed_private_subnets : "${subnet.tag}-${subnet.az}" => subnet }
  public_subnets  = { for subnet in local.transformed_public_subnets : "${subnet.tag}-${subnet.az}" => subnet }

  # Se existirem subnets publicas monta um mapa ordenando pelas tags, senão {} 
  check_public_subnets = length(var.public_subnets) > 0 ? { for i in var.public_subnets : i.tag => { "cidr" = i["cidr_blocks"] } } : {}

  # Se for single_nat recebe valor 1, senão recebe o valor máximo de subnets privadas existentes
  number_of_private_routes = var.single_nat ? 1 : max(values(local.public_subnets).*.index...) + 1
}