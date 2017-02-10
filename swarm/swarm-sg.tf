resource "aws_security_group" "swarm" {
  name        = "${var.vpc_key}-sg-swarm"
  description = "Security group for swarm cluster instances"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
      from_port   = 2375
      to_port     = 2377
      protocol    = "tcp"
      cidr_blocks = [
        "${aws_vpc.vpc.cidr_block}"
      ]
  }

  ingress {
      from_port   = 7946
      to_port     = 7946
      protocol    = "tcp"
      cidr_blocks = [
        "${aws_vpc.vpc.cidr_block}"
      ]
  }

  ingress {
      from_port   = 7946
      to_port     = 7946
      protocol    = "udp"
      cidr_blocks = [
        "${aws_vpc.vpc.cidr_block}"
      ]
  }

  ingress {
      from_port   = 4789
      to_port     = 4789
      protocol    = "tcp"
      cidr_blocks = [
        "${aws_vpc.vpc.cidr_block}"
      ]
  }

  ingress {
      from_port   = 4789
      to_port     = 4789
      protocol    = "udp"
      cidr_blocks = [
        "${aws_vpc.vpc.cidr_block}"
      ]
  }

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
    Name = "${var.vpc_key}-sg-swarm"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}
