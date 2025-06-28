variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
}

variable "env_prefix" {
  description = "Environment prefix for resource naming"
}

variable "instance_type" {
  description = "EC2 instance type"
}

variable "pub_key_location" {
  description = "Path to the SSH public key file"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
}
variable "image_name" {
  description = "Name of the AMI to use"
}