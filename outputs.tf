output "availability_zones_used-lb_test" {
  value = module.lb_test.available_zones
}

output "endpoint-lb-test" {
  value = "Check the running service in: ${module.lb_test.alb_dns_name}"
}

output "availability_zones_used-hello" {
  value = module.hello.available_zones
}

output "endpoint-hello" {
  value = "Check the running service in: ${module.hello.alb_dns_name}"
}


