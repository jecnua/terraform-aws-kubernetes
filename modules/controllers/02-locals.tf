locals {
  tags_as_map = merge(
    {
      "Name"               = format("k8s-controller-%s-%s-%s", var.unique_identifier, var.environment, random_string.seed.result)
      "Environment"        = format("%s", var.environment)
      "k8s.io/role/master" = "1" # Taken from the kops # TODO: CHECK
      "KubernetesCluster"  = var.kubernetes_cluster
      "ManagedBy"          = "terraform k8s module"
      "ModuleRepository"   = "https://github.com/jecnua/terraform-aws-kubernetes"
    },
    var.additional_tags_as_map,
  )
  tags_for_asg = null_resource.tags_as_list_of_maps.*.triggers
}

resource "null_resource" "tags_as_list_of_maps" {
  count = length(keys(local.tags_as_map))

  triggers = {
    "key"                 = keys(local.tags_as_map)[count.index]
    "value"               = values(local.tags_as_map)[count.index]
    "propagate_at_launch" = "true"
  }
}
