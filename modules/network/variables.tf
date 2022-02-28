variable "vpc_cidr" {
  type        = string
  description = "VPC cidr"
}

variable "prefix_name" {
  type        = string
  description = "Base name to be used as prefix"
}

variable "environment" {
  type        = string
  description = "Sets the default environment (development, staging, production)"
}

variable "automation_tag" {
  type        = string
  default     = "Terraform"
  description = "Tag indicating the automation tool used"
}

variable "subnet_cidrs" {
  type    = list(any)
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Indicate that instances launched into subnet should be assigned a public IP address"
}
