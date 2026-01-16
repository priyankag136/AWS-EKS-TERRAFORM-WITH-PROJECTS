terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

locals {
  name = "webserver"
}

resource "aws_vpc" "proj_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${local.name}-vpc"
  }
}

resource "aws_subnet" "public" {
  #count = 5
  vpc_id                  = aws_vpc.proj_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true
  tags = {
    # Name = "${local.name}-subnet${count.index}"
    Name = "${local.name}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  #count = 5
  vpc_id            = aws_vpc.proj_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.azs[1]

  tags = {
    # Name = "${local.name}-subnet${count.index}"
    Name = "${local.name}-private-subnet"
  }
}

resource "aws_internet_gateway" "internet_gtwy" {
  vpc_id = aws_vpc.proj_vpc.id
  tags = {
    Name = "${local.name}-internet-gtwy"
  }
}
/*
resource "aws_internet_gateway_attachment" "in-gtwy-attach" {
  vpc_id = aws_vpc.proj1-vpc.id
  internet_gateway_id = aws_internet_gateway.internet-gtwy.id
}*/

resource "aws_route_table" "route_tb" {
  vpc_id = aws_vpc.proj_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gtwy.id
  }
  tags = {
    Name = "${local.name}-router-public"
  }
}

resource "aws_route_table_association" "asso-router" {
  route_table_id = aws_route_table.route_tb.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.proj_vpc.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
  tags = {
    Name = "${local.name}-security-grp"
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "webserver" {
  vpc_security_group_ids      = [aws_security_group.sg.id]
  ami                         = data.aws_ami.ami.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  availability_zone           = var.azs[0]
  key_name                    = "paris-key"

   iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data                   = file("data.sh")
 
  /*
  user_data = <<-EOF
   #!/bin/bash
    yum update -y
    yum install -y httpd awscli
    systemctl start httpd
    systemctl enable httpd
    aws s3 cp s3://rosestore.fun/index.html /var/www/html/index.html --region us-east-1
    EOF
    */
  tags = {
    Name = "webserver-paris"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-read"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "rosestore-fun-read"
  description = "Allow EC2 to read index.html from rosestore.fun"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject"],
        Resource = ["arn:aws:s3:::rosestore.fun/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_custom" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2_role.name
}
