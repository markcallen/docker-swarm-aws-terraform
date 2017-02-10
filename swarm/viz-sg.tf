resource "aws_security_group" "viz" {
  name        = "${var.vpc_key}-sg-viz"
  description = "Security group for viz app"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
      from_port   = 8080
      to_port     = 8080
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
    Name = "${var.vpc_key}-sg-viz"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}
