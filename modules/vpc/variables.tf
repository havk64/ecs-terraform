variable "vpc_cidr" {
  type        = string
  description = "VPC cidr"
}

variable "name" {
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

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable/disable dns_hostnames on vpc"
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable/disable vpc dns support"
}