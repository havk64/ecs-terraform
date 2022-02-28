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