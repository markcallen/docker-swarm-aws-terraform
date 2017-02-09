provider "aws" {
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.vpc_key}-ig"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_network_acl" "network" {
  vpc_id = "${aws_vpc.vpc.id}"
  subnet_ids = [
    "${aws_subnet.a.id}"
  ]

  ingress {
    from_port = 0
    to_port = 0
    rule_no = 100
    action = "allow"
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    from_port = 0
    to_port = 0
    rule_no = 100
    action = "allow"
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
  }

  tags {
    Name = "${var.vpc_key}-network"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.vpc_key}-route"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_route_table_association" "a" {
  route_table_id = "${aws_route_table.main.id}"
  subnet_id = "${aws_subnet.a.id}"
}

resource "aws_subnet" "a" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,1)}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.vpc_key}-a"
    VPC = "${var.vpc_key}"
    Terraform = "Terraform"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.5.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags {
    VPC = "${var.vpc_key}"
    Name = "${var.vpc_key}-vpc"
    Terraform = "Terraform"
  }
}

