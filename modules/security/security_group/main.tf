resource "aws_security_group" "main" {
  vpc_id = var.vpc_id
  name   = var.name

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.36.0.0/19"]
    description = "allow HTTPS for ec2 and ssm"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}
