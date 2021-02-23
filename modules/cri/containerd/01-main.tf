data "template_file" "bootstrap_k8s_cri_installation_containerd" {
  template = file("${path.module}/scripts/cri-containerd-gvisor.sh")
  vars = {
  }
}

output "cri_bootstrap" {
  value = data.template_file.bootstrap_k8s_cri_installation_containerd.rendered
}