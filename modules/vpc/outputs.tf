output "id" {
  value = aws_vpc.stage.id
}

output "gw_id" {
  value = aws_internet_gateway.gw.id
}