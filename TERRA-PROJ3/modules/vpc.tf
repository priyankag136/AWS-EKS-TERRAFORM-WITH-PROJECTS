locals {
  region = "paris"
}

resource "aws_vpc" "paris_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${local.region}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.paris_vpc.id
  cidr_block = var.public_subnet_cidr[count.index]
  tags = {
    Name = "${local.region}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.paris_vpc.id
  cidr_block = var.private_subnet_cidr[count.index]
  tags = {
    Name = "${local.region}-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "paris_gtwy" {
  vpc_id = aws_vpc.paris_vpc.id
  tags = {
    Name = "${local.region}-internet-gateway"
  }
}

resource "aws_route_table" "rt_public" {
 vpc_id = aws_vpc.paris_vpc.id
 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.paris_gtwy.id
 }  
}

resource "aws_route_table_association" "rt_ass" {
   count          = length(aws_subnet.public_subnet)
  route_table_id = aws_route_table.rt_public.id
  subnet_id = aws_subnet.public_subnet[count.index].id
}

resource "aws_nat_gateway" "nat_gtwy" {
  subnet_id = aws_subnet.public_subnet[0].id   # NAT must be in a public subnet
  allocation_id = aws_eip.nat_eip.id          # you need an Elastic IP
  tags = {
    Name = "${local.region}-nat-gateway"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc" 
}


resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.paris_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gtwy.id
  }
}

resource "aws_route_table_association" "rt_ass1" {
   count          = length(aws_subnet.private_subnet)
  route_table_id = aws_route_table.rt_private.id
  subnet_id = aws_subnet.private_subnet[count.index].id
}

resource "aws_security_group" "paris_sg" {
  vpc_id = aws_vpc.paris_vpc.id
  ingress = [ {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks=[]
    prefix_list_ids=[]
    security_groups= []
    self= false
  },
  {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
    ipv6_cidr_blocks=[]
    prefix_list_ids=[]
    security_groups= []
    self= false
  } ]
  
  egress = [ {
    description = "All Traffic ports"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks=[]
    prefix_list_ids=[]
    security_groups= []
    self= false
  } ]

  tags = {
    Name = "${local.region}-security-grp"
  }
  
}

resource "aws_instance" "paris_server1" {
  ami = var.ami_server
  instance_type = var.instance_type
  key_name = "paris-key"
  subnet_id = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [ aws_security_group.paris_sg.id ]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get install apache2 -y
  sudo mkdir -p /var/www/html
  echo "Welcome to public instance 1 of public subnet" >> /var/www/html/index.html
  hostname >> /var/www/html/index.html
  systemctl start apache2
  systemctl enable apache2
  EOF

  tags = {
    Name = "${local.region}-public-server-webhosting1"
  }
}

resource "aws_instance" "paris_server2" {
  ami = var.ami_server
  instance_type = var.instance_type
  key_name = "paris-key"
  subnet_id = aws_subnet.private_subnet[0].id
  vpc_security_group_ids = [ aws_security_group.paris_sg.id ]
  associate_public_ip_address = false

  tags = {
    Name = "${local.region}-private-server-webhosting1"
  }
}

output "public_ip_server1" {
  description = "Public IP of public EC2 instance1"
  value       = aws_instance.paris_server1.public_ip
}

output "private_ip_server1" {
  description = "Private IP of private EC2 instance1"
  value = aws_instance.paris_server2.private_ip
}
