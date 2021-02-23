data "template_file" "bootstrap_k8s_cri_installation_docker" {
  template = file("${path.module}/scripts/cri-docker.sh")
  vars = {
  }
}

output "cri_bootstrap" {
  value = data.template_file.bootstrap_k8s_cri_installation_docker.rendered
}