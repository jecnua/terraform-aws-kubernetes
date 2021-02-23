data "aws_partition" "current" {}

data "aws_vpc" "targeted_vpc" {
  id      = var.vpc_id
  default = false
  state   = "available"
}

data "template_file" "bootstrap_k8s_controllers_kubeadm_join_config" {
  template = file("${path.module}/scripts/kubeadm_join_config.yaml")
  vars = {
    controller_join_token = local.controller_join_token
  }
}

data "template_file" "bootstrap_node_k8s_workers" {
  template = file("${path.module}/scripts/bootstrap.sh")

  vars = {
    controller_join_token   = local.controller_join_token
    cluster_id              = local.kubernetes_cluster
    k8s_deb_package_version = local.k8s_deb_package_version
    pre_install             = var.userdata_pre_install
    post_install            = var.userdata_post_install
    kubeadm_join_config     = data.template_file.bootstrap_k8s_controllers_kubeadm_join_config.rendered
    cri_installation        = var.nodes_cri_bootstrap
  }
}
