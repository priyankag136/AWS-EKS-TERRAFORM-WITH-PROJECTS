variable "aws_region" {
  default = "eu-west-3"
}

variable "ami_id" {
  description = "Amazon Linux 2 AMI"
  default     = "ami-0f95dedaf2f938d49"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_pair_name" {
  description = "paris-key-pair-name"
  default = "paris-key"
}
/*
variable "my_ip" {
  description = "Your public IP with /32"
  #default     = [aws_instance.app_ec2.public_ip]/32
}
*/

variable "db_name" {
  default = "app_db"
}

variable "db_username" {
  default = "admin"
}

variable "db_password" {
  default = "Priyanka123!"
  sensitive = true
}