provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "dynamic-subnet-vpc"
  }
}

locals {
  # Generate a map of subnet configurations, keyed by a unique identifier
  # combining subnet type and AZ.
  # This makes it easy to iterate with for_each and reference specific subnets later.
  subnets = merge([
    for az in var.availability_zones : {
      for type, config in var.subnet_configs :
      "${type}-${az}" => {
        name              = "${type}-${az}"
        type              = type
        availability_zone = az
        cidr_block        = cidrsubnet(
          aws_vpc.main.cidr_block,
          config.newbits,
          index(var.availability_zones, az) + config.netnum_offset
        )
      }
    }
  ]...)
}

resource "aws_subnet" "dynamic" {
  for_each          = local.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.value.name
    Type = each.value.type
  }
}


output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value = {
    for k, v in aws_subnet.dynamic :
    k => v.id
    if v.tags.Type == "public"
  }
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value = {
    for k, v in aws_subnet.dynamic :
    k => v.id
    if v.tags.Type == "private"
  }
}
