output "aws_ami_id" {
  value       = data.aws_ami.latest_ecs_ami.image_id
  description = "The Image ID of latest ecs optimized ami image"
}

output "vpc_id" {
  value       = module.vpc.id
  description = "VPC cluster ID"
}

output "subnets" {
  value       = aws_subnet.public.*.id
  description = "List of created subnets"
}

output "default_alb_target_group" {
  value       = aws_alb_target_group.default.arn
  description = "Application load balancer ARN"
}

output "alb_dns_name" {
  value       = aws_alb.main.dns_name
  description = "Application load balancer dns name"
}

output "ecs_cluster_id" {
  value       = aws_ecs_cluster.groover.id
  description = "ECS cluster ID"
}

output "available_zones" {
  value       = aws_subnet.public.*.availability_zone
  description = "List of availability zones where the instances are deployed"
}