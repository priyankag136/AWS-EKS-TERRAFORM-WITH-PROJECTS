variable "vpc_cidr" {
  description = "this is vpc-cidr"
  type = string
}

variable "public_subnet_cidr" {
  description = "This is public subnet cidr"
  type = list(string)
}

variable "private_subnet_cidr" {
  description = "This is private subnet cidr"
  type = list(string)
}

variable "ami_server" {
  description = "ami for server of paris"
  type = string
}

variable "instance_type" {
  description = "instance type of paris server for static web hosting"
  type = string
}

variable "azs" {
  type = list(string)
}
