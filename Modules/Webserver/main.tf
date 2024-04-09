resource "aws_default_security_group" "myapp-sg" {
  vpc_id = var.vpc_id

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
    values = [ var.image_name]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.my_pub_location)
  
}

resource "aws_instance" "aws-server" {
  ami = data.aws_ami.latest-linux-amazon-image.id
  instance_type = var.instance_type

  subnet_id = module.myapp-subnet.subnet.id
  vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")

  tags = {
    name: "${var.env_prefix}-server"
  }
  
}

