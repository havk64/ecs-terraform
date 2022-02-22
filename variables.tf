variable "prefix_name" {
    type = string
    default = "groover"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
    type = list
    default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "enable_dns_hostnames" {
    type = bool
    default = true
}

variable "environment" {
    type = string
    default = "development"
}
variable "enable_dns_support" {
    type = bool
    default = true
}

variable "map_public_ip_on_launch" {
    type = bool
    default = true
}

variable "create_before_destroy" {
    type = bool
    default = true
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "aws_ami" {
    type = string
    default = ""
}

variable "ssh_key_name" {
  type = string
  default = ""
}

variable "aws_region" {
    type = string
    default = "eu-west-3"
}

variable "service_name" {
  type = string
  default = "hello"
}

variable "ec2_desired_count" {
    type = number
    default = 2
}

variable "asg_min_size" {
    type = number
    default = 2
}

variable "asg_max_size" {
    type = number
    default = 8
}

variable "task_family_name" {
  type        = string
  default     = "hello"
}

variable "container_image" {
  type        = string
}

variable "container_port" {
  type        = number
}

variable "container_healthcheck_path" {
  type = string
  default = "/"
}

variable "host_port" {
  type        = number
  default     = 0
}

variable "task_definition_name" {
  type        = string
}

variable "cpu" {
  type        = number
  default     = 1
}

variable "memory" {
  type        = number
  default     = 128
}

variable "ecs_desired_count" {
  type        = number
  default     = 2
}

variable "lb_internal_protocol" {
    type = string
    default = "HTTP"
}

variable "associate_public_ip" {
    type = bool
    default = true
}

variable "automation_tag" {
  type = string
  default = "Terraform"
}
