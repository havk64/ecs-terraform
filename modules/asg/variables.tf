variable "vpc_id" {
  type        = string
  description = "ID of VPC to be used"
}

variable "ssh_cidr_block" {
  type    = list(string)
  default = ["0.0.0.0/0"]
  description = "Cidr block for ssh connections on port 22"
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

variable "aws_ami" {
  type        = string
  default     = ""
  description = "The AWS ami id to use"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type"
}

variable "associate_public_ip" {
  type        = bool
  description = "Associate a public ip address with an instance in a VPC" // TODO: improve description
}

variable "ec2_desired_count" {
  type        = number
  default     = 2
  description = "Number of ec2 instances to be launched by Auto Scaling Group"
}

variable "asg_min_size" {
  type        = number
  default     = 2
  description = "Minimum size for ec2 Auto Scaling Group"
}

variable "asg_max_size" {
  type    = number
  default = 8
}

variable "ssh_key_name" {
  type        = string
  default     = ""
  description = "SSH public key used to access EC2 instances"
}

variable "public_subnet_ids" {
  type = list(string)
  description = "List of public subnet ids"
}
