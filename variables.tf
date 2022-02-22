variable "prefix_name" {
  type = string
  default = "groover"
  description = "Base name to be used as prefix"
}
 
variable "environment" {
  type        = string
  default     = "development"
  description = "Sets the default environment (development, staging, production)"
}
 
variable "service_name" {
  type = string
  default = "hello"
  description = "Name of the ECS service"
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
}

variable "ec2_desired_count" {
  type        = number
  default     = 2
  description = "Number of ec2 instances to be launched by Auto Scaling Group"
}

variable "container_image" {
  type        = string
  description = "Container image"
}

variable "container_port" {
  type        = number
  description = "Tcp port number of a container"
}

variable "task_definition_name" {
  type        = string
  description = "Name of related Task Definition"
}

variable "automation_tag" {
  type        = string
  default     = "Terraform"
  description = "Tag indicating the automation tool used"
}

variable "ecs_desired_count" {
  type        = number
  default     = 2
  description = "Number of ECS instances of task to deploy and keep running"
}

variable "cpu" {
  type        = number
  default     = 1
  description = "Number of CPU units used by the task"
}

variable "memory" {
  type        = number
  default     = 128
  description = "Amount of memory in MiB used by the task"
}
