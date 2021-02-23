output "nodes_subnets_private_id" {
  description = "The nodes subnets id"
  value       = aws_subnet.k8s_private.*.id
}

output "nodes_subnets_public_id" {
  description = "The nodes subnets id"
  value       = [aws_subnet.k8s_public.*.id]
}

output "controller_elb_internal_dns_name" {
  description = "The AWS DNS name of the controller nodes ELB"
  value       = aws_elb.k8s_controllers_internal_elb.dns_name
}

output "controller_elb_internal_zone_id" {
  description = "The AWS zone id for the controller nodes ELB"
  value       = aws_elb.k8s_controllers_internal_elb.zone_id
}

//output "controllers_sd_id" {
//  description = "The id of the controllers sg. Allows injection of rules aws_security_group_rule"
//  value       = aws_security_group.k8s_controllers_node_sg.id
//}

output "k8s_role_id" {
  description = "The role the nodes use. Can be used to attach policies"
  value       = aws_iam_role.k8s_assume_role.id
}

output "private_route_table_id" {
  description = "The id of the PRIVATE route table"
  value       = aws_route_table.k8s_private_route_table.id
}

output "public_route_table_id" {
  description = "The id of the PUBLIC route table"
  value       = aws_route_table.k8s_public_route_table.id
}

output "controller_join_token" {
  value = var.controller_join_token
}

output "unique_identifier" {
  value = var.unique_identifier
}

output "kubernetes_cluster" {
  value = var.kubernetes_cluster
}

output "k8s_deb_package_version" {
  value = var.k8s_deb_package_version
}

output "nodes_config_bundle" {
  value = {
    "environment"             = var.environment
    "k8s_deb_package_version" = var.k8s_deb_package_version
    "kubernetes_cluster"      = var.kubernetes_cluster
    "controller_join_token"   = var.controller_join_token
    "unique_identifier"       = var.unique_identifier
    "controllers_sg_id"       = aws_security_group.k8s_controllers_node_sg.id
    "internal_network_cidr"   = var.internal_network_cidr
  }
}
