resource "aws_vpc" "stage" {
  cidr_block           = var.vpc_cidr // default: "10.0.0.0/16": 10.0.0.0 => 10.0.255.255 = 65.536
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name        = var.name
    Environment = var.environment
    Automation  = var.automation_tag
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.stage.id

  tags = {
    Environment = var.environment
    Automation  = var.automation_tag
  }
}
