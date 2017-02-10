resource "aws_instance" "swarm-manager" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "t2.small"
    count = "${var.cluster_manager_count}"
    associate_public_ip_address = "true"
    key_name = "${var.ssh_key_name}"
    subnet_id = "${element(list(aws_subnet.a.id, aws_subnet.b.id), count.index % 2)}"
    vpc_security_group_ids      = [
      "${aws_security_group.swarm.id}"
    ]

    root_block_device = {
      volume_size = 100
    }

    connection {
      user = "ubuntu"
      private_key = "${file("${var.ssh_key_filename}")}"
      agent = false
    }

    tags {
      Name = "${var.vpc_key}-manager-${count.index}"
      VPC = "${var.vpc_key}"
      Terraform = "Terraform"
    }

    provisioner "remote-exec" {
      inline = [
        "if [ ${count.index} -eq 0 ]; then sudo docker swarm init; else sudo docker swarm join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q manager); fi"
      ]
    }
}

resource "aws_instance" "swarm-node" {
    ami = "${lookup(var.amis, var.aws_region)}"
    instance_type = "t2.small"
    count = "${var.cluster_node_count}"
    associate_public_ip_address = "true"
    key_name = "${var.ssh_key_name}"
    subnet_id = "${element(list(aws_subnet.a.id, aws_subnet.b.id), count.index % 2)}"
    vpc_security_group_ids = [
      "${aws_security_group.swarm.id}"
    ]

    root_block_device = {
      volume_size = 100
    }

    connection {
      user = "ubuntu"
      private_key = "${file("${var.ssh_key_filename}")}"
      agent = false
    }

    tags {
      Name = "${var.vpc_key}-node-${count.index}"
      VPC = "${var.vpc_key}"
      Terraform = "Terraform"
    }

    provisioner "remote-exec" {
      inline = [
        "sudo docker swarm join ${aws_instance.swarm-manager.0.private_ip}:2377 --token $(docker -H ${aws_instance.swarm-manager.0.private_ip} swarm join-token -q worker)",
      ]
    }

    depends_on = [
      "aws_instance.swarm-manager"
    ]
}

resource "null_resource" "cluster" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.swarm-node.*.id)}"
  }

  connection {
    host = "${element(aws_instance.swarm-manager.*.public_ip, 0)}"
    user = "ubuntu"
    private_key = "${file("${var.ssh_key_filename}")}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "docker -H ${element(aws_instance.swarm-manager.*.private_ip, 0)}:2375 network create --driver overlay appnet",
      "docker -H ${element(aws_instance.swarm-manager.*.private_ip, 0)}:2375 service create --name viz --publish 8080:8080 --constraint node.role==manager --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock --network appnet manomarks/visualizer"
    ]
  }
}
