output "aws_ami_id" {
  value = data.aws_ami.latest-linux-amazon-image.id
  
}

output "ec2_public_ip" {
  value = aws_instance.aws-server.public_ip
  
}