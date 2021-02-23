data "template_file" "bootstrap_k8s_cri_installation_docker" {
  template = file("${path.module}/scripts/cri-o.sh")
  vars = {
    crio_version = var.crio_version
  }
}

output "cri_bootstrap" {
  value = data.template_file.bootstrap_k8s_cri_installation_docker.rendered
}
