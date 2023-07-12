# This code creates a VPC and a default security group.

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  instance_tenancy = var.tenancy
  tags = {
    Name = var.name
  }
}

# Create a default security group
resource "aws_security_group" "default_sg" {
  name   = "default_sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "default_sg"
  }
}
