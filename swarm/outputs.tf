output "swarm_managers" {
  value = "${concat(aws_instance.swarm-manager.*.public_dns)}"
}
output "swarm_nodes" {
  value = "${concat(aws_instance.swarm-node.*.public_dns)}"
}

