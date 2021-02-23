//variable "network_region" {
//  type        = string
//  description = "The AWS region where to spin the infrastructure"
//}

//variable "unique_identifier" {
//  type        = string
//  description = "A UUID to be used in resource names generation to avoid conflicts"
//}

//variable "environment" {
//  type        = string
//  description = "The environment to use"
//}

//variable "controller_join_token" {
//  type        = string
//  description = "kubeadm control join token. This needs to be unique for each cluster"
//}

//variable "kubernetes_cluster" {
//  type        = string
//  description = "Cluster name indentifier"
//}

variable "vpc_id" {
  type        = string
  description = "The VPC id"
}

variable "ec2_k8s_workers_instance_type" {
  type        = string
  description = "Instance size for the nodes"
}

variable "k8s_workers_num_nodes" {
  type        = string
  description = "Number of nodes for the asg for the nodes"
}

//variable "internal_network_cidr" {
//  type        = string
//  description = "TEMPORARY: Allow access from a certain ip range" # TODO: FIXME: This needs to be removed and the sg exported
//}

variable "nodes_cri_bootstrap" {
  type = string
}

variable "private_subnets" {
  //  type = list(string)
}

//variable "controller_sg_id" {
//  type = string
//}

variable "nodes_config_bundle" {

}
