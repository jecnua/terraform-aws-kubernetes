output "nodes_sd_id" {
  description = "The id of the nodes (workers) sg. Allows injection of rules aws_security_group_rule"
  value       = aws_security_group.k8s_workers_node_sg.id
}