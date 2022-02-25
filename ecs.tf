provider "aws" {
  region = var.aws_region
}
// Example 1 (hard coded values):
module "hello" {
  source = "./modules/ecs"

  prefix_name          = "hello"
  aws_region           = "eu-west-3" // Paris
  ec2_desired_count    = 2
  environment          = "development"
  service_name         = "hello"
  container_image      = "digitalocean/flask-helloworld"
  container_port       = 5000
  task_definition_name = "hello_world"
  cpu                  = 1
  memory               = 128
  ecs_desired_count    = 4
  automation_tag       = "Terraform"
}


// Example 2 (using vars file and uploading ssh pub key to EC2 instances):
module "lb_test" {
  source = "./modules/ecs"

  prefix_name          = var.prefix_name
  aws_region           = var.aws_region
  ec2_desired_count    = var.ec2_desired_count
  environment          = var.environment
  service_name         = var.service_name
  container_image      = var.container_image
  container_port       = var.container_port
  task_definition_name = var.task_definition_name
  cpu                  = var.cpu
  memory               = var.memory
  ecs_desired_count    = var.ecs_desired_count
  ssh_key_name         = aws_key_pair.admin.key_name // using the resource created below
}

// The file 'id_rsa.pub' needs to be in the same level as the current file
resource "aws_key_pair" "admin" {
  key_name = "admin"
  public_key = file("${path.module}/id_rsa.pub")
}

