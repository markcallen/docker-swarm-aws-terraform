variable "aws_region" {
}

variable "ssh_key_name" {
}

variable "ssh_key_filename" {
}

variable "amis" {
  type = "map"
}

variable "vpc_key" {
  description = "A unique identifier for the VPC."
  default     = "swarm"
}

variable "cluster_manager_count" {
    description = "Number of manager instances for the swarm cluster."
    default = 2
}

variable "cluster_node_count" {
    description = "Number of node instances for the swarm cluster."
    default = 4
}
