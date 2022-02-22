output "aws_ami_id" {
    value = data.aws_ami.latest_ecs_ami.image_id
}

output "vpc_id" {
  value = aws_vpc.stage.id
}

output "subnets" {
    value = aws_subnet.public.*.id
}

output "default_alb_target_group" {
  value = aws_alb_target_group.default.arn
}

output "alb_dns_name" {
  value = aws_alb.main.dns_name
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.groover.id
}

output "available_zones" {
  value = aws_subnet.public.*.availability_zone
}