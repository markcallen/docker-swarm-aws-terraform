resource "aws_security_group" "packer" {
  name        = "${var.vpc_key}-sg-packer"
  description = "Security group for packer"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
  }

  tags {
    Name = "${var.vpc_key}-sg-packer"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

