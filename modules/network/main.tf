locals {
  cluster_name = "${var.prefix_name}-${var.environment}"
}

module "vpc" {
  source = "../vpc"

  vpc_cidr = var.vpc_cidr // default: "10.0.0.0/16" = 10.0.0.0 => 10.0.255.255 = 65.536 nodes
  enable_dns_hostnames = true
  enable_dns_support = true
  name = local.cluster_name
  environment = var.environment
  automation_tag = var.automation_tag
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  vpc_id                  = module.vpc.id
  count                   = length(var.subnet_cidrs)
  cidr_block              = element(var.subnet_cidrs, count.index) // default: 10.0.0.0 -> 10.0.0.255 = 256
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch // default: true

  tags = {
    Name        = "${var.prefix_name}_${element(data.aws_availability_zones.available.names, count.index)}"
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_route_table" "public" {
  vpc_id = module.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.vpc.gw_id
  }
  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public.*.id)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}