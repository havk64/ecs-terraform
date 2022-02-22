variable "prefix_name" {
    type = string
    default = "groover"
    description = "Base name to be used as prefix"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "VPC cidr"
}

variable "subnet_cidrs" {
    type = list
    default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "enable_dns_hostnames" {
    type = bool
    default = true
    description = "Enable/disable dns_hostnames on vpc"
}

variable "environment" {
    type = string
    default = "development"
    description = "Sets the default environment (development, staging, production)"
}
variable "enable_dns_support" {
    type = bool
    default = true
    description = "Enable/disable vpc dns support"
}

variable "map_public_ip_on_launch" {
    type = bool
    default = true
    description = "Indicate that instances launched into subnet should be assigned a public IP address"
}

variable "create_before_destroy" {
    type = bool
    default = true
    description = "When update in place is not allowed create new instances before destroy the old ones"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
    description = "EC2 instance type"
}

variable "aws_ami" {
    type = string
    default = ""
    description = "The AWS ami id to use"
}

variable "ssh_key_name" {
  type = string
  default = ""
  description = "SSH public key used to access EC2 instances"
}

variable "aws_region" {
    type = string
    default = "eu-west-3"
    description = "The AWS region"
}

variable "service_name" {
  type = string
  default = "hello"
  description = "Name of the ECS service"
}

variable "ec2_desired_count" {
    type = number
    default = 2
    description = "Number of ec2 instances to be launched by Auto Scaling Group"
}

variable "asg_min_size" {
    type = number
    default = 2
    description = "Minimum size for ec2 Auto Scaling Group"
}

variable "asg_max_size" {
    type = number
    default = 8
}

variable "task_family_name" {
  type        = string
  default     = "hello"
  description = "Task's family name"
}

variable "container_image" {
  type        = string
  description = "Container image"
}

variable "container_port" {
  type        = number
  description = "Tcp port number of a container"
}

variable "container_healthcheck_path" {
  type = string
  default = "/"
  description = "Path to the container healthcheck"
}

variable "host_port" {
  type        = number
  default     = 0
  description = "Tcp port number in the host"
}

variable "task_definition_name" {
  type        = string
  description = "Name of related Task Definition"
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

variable "ecs_desired_count" {
  type        = number
  default     = 2
  description = "Number of ECS instances of task to deploy and keep running"
}

variable "lb_internal_protocol" {
    type = string
    default = "HTTP"
    description = "Protocol for internal communication"
}

variable "associate_public_ip" {
    type = bool
    default = true
    description = "Associate a public ip address with an instance in a VPC"
}

variable "automation_tag" {
  type = string
  default = "Terraform"
  description = "Tag indicating the automation tool used"
}
