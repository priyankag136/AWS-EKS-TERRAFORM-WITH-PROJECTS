variable "vpc_cidr" {
  description = "cidr of proj1-vpc"
  type        = string
}

variable "public_subnet_cidr" {
  description = "subnet cidr of proj1-vpc"
  type        = string
}

variable "private_subnet_cidr" {
  description = "subnet cidr of proj1-vpc"
  type        = string
}

variable "azs" {
  description = "Availability zone of subnets"
  type        = list(string)
}

variable "instance_type" {
  type = string
}