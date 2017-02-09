output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_subnet_a" {
  value = "${aws_subnet.a.id}"
}

output "security_group_id" {
  value = "${aws_security_group.packer.id}"
}

