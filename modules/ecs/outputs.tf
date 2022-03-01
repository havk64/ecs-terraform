output "subnets" {
  value       = module.network.public_subnets.*.id
  description = "List of created subnets IDs"
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
  value       = module.network.public_subnets.*.availability_zone
  description = "List of availability zones where the instances are deployed"
}