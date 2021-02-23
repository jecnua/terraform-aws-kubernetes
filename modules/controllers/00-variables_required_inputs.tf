###################################### General

variable "unique_identifier" {
  type        = string
  description = "A UUID to be used in resource names generation to avoid conflicts"
}

variable "environment" {
  type        = string
  description = "The environment to use"
}

variable "controller_join_token" {
  type        = string
  description = "kubeadm control join token. This needs to be unique for each cluster"
}

variable "kubernetes_cluster" {
  type        = string
  description = "Cluster name indentifier"
}

###################################### Network

variable "vpc_id" {
  type        = string
  description = "The VPC id"
}

variable "subnets_private_cidr_block" {
  type        = list(string)
  description = "The CIDR to use when creating private subnets"
}

variable "subnets_public_cidr_block" {
  type        = list(string)
  description = "The CIDR to use when creating public subnets"
}

###################################### EC2

variable "ec2_k8s_controllers_instance_type" {
  type        = string
  description = "Instance size for the nodes"
}

variable "k8s_controllers_num_nodes" {
  type        = string
  description = "Number of nodes in the asg for the controllers"
}

###################################### Bootstrap

variable "internal_network_cidr" {
  type        = string
  description = "TEMPORARY: Allow access from a certain ip range" # TODO: FIXME: This needs to be removed and the sg exported
}

variable "controllers_cri_bootstrap" {
  type = string
}
