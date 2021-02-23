data "template_file" "bootstrap_node_k8s_controllers" {
  template = file("${path.module}/scripts/bootstrap.sh")

  vars = {
    controller_join_token = var.controller_join_token
    //    cluster_id              = var.kubernetes_cluster
    k8s_deb_package_version = var.k8s_deb_package_version
    kubeadm_install_version = var.kubeadm_install_version
    //    load_balancer_dns       = aws_elb.k8s_controllers_external_elb.dns_name
    pre_install             = var.userdata_pre_install
    cni_install             = var.userdata_cni_install
    post_install            = var.userdata_post_install
    kubeadm_config          = data.template_file.bootstrap_k8s_controllers_kubeadm_config.rendered
    kubeadm_etcd_encryption = data.template_file.bootstrap_k8s_controllers_kubeadm_etcd_encryption.rendered
    cri_installation        = var.controllers_cri_bootstrap
    audit_policy            = data.template_file.bootstrap_audit_config_policy_file_yaml.rendered
  }
}

data "template_file" "bootstrap_k8s_controllers_kubeadm_config" {
  template = file("${path.module}/scripts/kubeadm_config.yaml")
  vars = {
    k8s_deb_package_version  = var.k8s_deb_package_version
    controller_join_token    = var.controller_join_token
    enable_admission_plugins = var.enable_admission_plugins
  }
}

data "template_file" "bootstrap_audit_config_policy_file_yaml" {
  template = file("${path.module}/scripts/audit-policy.yaml")
  vars     = {}
}

data "template_file" "bootstrap_k8s_controllers_kubeadm_etcd_encryption" {
  template = file("${path.module}/scripts/etcd_enc.yaml")
  vars     = {}
}

resource "aws_elb" "k8s_controllers_internal_elb" {
  name                      = "${var.unique_identifier}-${var.environment}-ctrl-int-elb"
  subnets                   = aws_subnet.k8s_private.*.id
  idle_timeout              = var.k8s_controllers_lb_timeout_seconds
  internal                  = true
  cross_zone_load_balancing = true
  connection_draining       = true

  listener {
    instance_port     = 6443
    instance_protocol = "tcp"
    lb_port           = 6443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:6443"
    interval            = 30
  }

  security_groups = [
    aws_security_group.k8s_controllers_internal_elb_ag_sg.id,
  ]

  tags = {
    Environment       = var.environment
    ManagedBy         = "terraform k8s module"
    ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
    Name              = "${var.unique_identifier} ${var.environment} controllers internal elb"
    KubernetesCluster = var.kubernetes_cluster
  }
}

# External ELB to connect to the api
//resource "aws_elb" "k8s_controllers_external_elb" {
//  name                      = "${var.unique_identifier}-${var.environment}-ctrl-ext-elb"
//  subnets                   = aws_subnet.k8s_public.*.id
//  idle_timeout              = var.k8s_controllers_lb_timeout_seconds
//  internal                  = false
//  cross_zone_load_balancing = true
//  connection_draining       = true
//
//  listener {
//    instance_port     = 6443
//    instance_protocol = "http"
//    lb_port           = 6443
//    lb_protocol       = "http"
//  }
//
//  health_check {
//    healthy_threshold   = 2
//    unhealthy_threshold = 3 #90 seconds
//    timeout             = 10
//    target              = "TCP:22" # TODO
//    interval            = 15
//  }
//
//  security_groups = [
//    aws_security_group.k8s_controllers_internal_elb_ag_sg.id,
//  ]
//
//  tags = {
//    Environment       = var.environment
//    ManagedBy         = "terraform k8s module"
//    ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
//    Name              = "${var.unique_identifier} ${var.environment} controllers external elb"
//    KubernetesCluster = var.kubernetes_cluster
//  }
//}

# TODO: Close this to outside and make it injectable
resource "aws_security_group" "k8s_controllers_internal_elb_ag_sg" {
  name        = "kubernetes-master-${var.kubernetes_cluster}"
  vpc_id      = data.aws_vpc.targeted_vpc.id
  description = "Security group for masters"

  # ingress {
  #   from_port = 6443
  #   to_port   = 6443
  #   protocol  = "tcp"
  #
  #   cidr_blocks = [
  #     var.internal_network_cidr,
  #   ]
  # }

  ingress {
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = [
      var.internal_network_cidr,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment       = var.environment
    ManagedBy         = "terraform k8s module"
    ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
    Name              = "${var.unique_identifier} ${var.environment} controllers internal elb sg"
    KubernetesCluster = var.kubernetes_cluster
  }
}

# SG of the node itself
resource "aws_security_group" "k8s_controllers_node_sg" {
  vpc_id = data.aws_vpc.targeted_vpc.id

  tags = {
    Environment       = var.environment
    ManagedBy         = "terraform k8s module"
    ModuleRepository  = "https://github.com/jecnua/terraform-aws-kubernetes"
    Name              = "${var.unique_identifier} ${var.environment} controllers sg"
    KubernetesCluster = var.kubernetes_cluster
  }
}

# Allow egress
resource "aws_security_group_rule" "allow_all_egress_from_k8s_controller_nodes" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_controllers_node_sg.id
  type              = "egress"
}

# FIXME: TMP
# FIXME: THIS NEED TO BE INJECTABLE BUT NOT HERE
resource "aws_security_group_rule" "allow_all_from_us_controllers" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.internal_network_cidr]
  security_group_id = aws_security_group.k8s_controllers_node_sg.id
  type              = "ingress"
}

# Allow ALL connection from other nodes like me
resource "aws_security_group_rule" "allow_all_from_self_controllers" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.k8s_controllers_node_sg.id
  type              = "ingress"
}

# Allow TCP connections from the ELB
resource "aws_security_group_rule" "allow_all_from_k8s_controller_internal_elb" {
  from_port                = 0
  to_port                  = 0
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_controllers_internal_elb_ag_sg.id
  security_group_id        = aws_security_group.k8s_controllers_node_sg.id
  type                     = "ingress"
}
