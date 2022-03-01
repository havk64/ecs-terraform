output "vpc_id" {
  value = module.vpc.id
  description = "ID of VPC to be used"
}

output "public_subnets" {
  value = aws_subnet.public
}