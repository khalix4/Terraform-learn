provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      name: "${var.env_prefix}-vpc"
    }
  
}

module "myapp-subnet" {
  source = "./Modules/Subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  
}

module "myapp-server" {
  source = "./Modules/Webserver"
  vpc_id = aws_vpc.myapp-vpc.id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  my_pub_location = var.my_pub_location
  subnet_id = module.myapp-subnet.id
  avail_zone = var.avail_zone
  image_name = var.image_name
}