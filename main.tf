provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable avail_zone {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {
  
}
variable "my_pub_location" {
  
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      name: "${var.env_prefix}-vpc"
    }
  
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      name: "${var.env_prefix}-subnet-1"
    }
  
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
     name: "${var.env_prefix}-igw"
  }
  
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    name: "${var.env_prefix}-main-rtb"
  }
}

resource "aws_default_security_group" "myapp-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]

  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []

  }

  tags = {
    name: "${var.env_prefix}-default_sg"
  }
  
}

data "aws_ami" "latest-linux-amazon-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [ "amzn2-ami-kernel-*-x86_64-gp2" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

output "aws_ami_id" {
  value = data.aws_ami.latest-linux-amazon-image.id
  
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.my_pub_location)
  
}

resource "aws_instance" "aws-server" {
  ami = data.aws_ami.latest-linux-amazon-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  tags = {
    name: "${var.env_prefix}-server"
  }
  
}

