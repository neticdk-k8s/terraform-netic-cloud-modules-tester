output "k8s_cluster_id" {
  value       = one(module.k8s_cluster[*].cluster_id)
  description = "ID of the K8s cluster. Returns null if deploy = false."
}

output "k8s_cluster_name" {
  value       = one(module.k8s_cluster[*].cluster_name)
  description = "The name of the K8s cluster. Returns null if deploy = false."
}

output "k8s_node_pools" {
  value       = one(module.k8s_cluster[*].node_pool_ids)
  description = "Map of the created node pools. Returns null if deploy = false."
}