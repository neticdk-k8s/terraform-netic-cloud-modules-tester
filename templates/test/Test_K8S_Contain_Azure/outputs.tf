
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.network.network_id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.network.subnet_ids
}

/*
output "registry_url" {
  description = "Login server URL for the container registry"
  value       = module.registry.registry_url
}

output "registry_user_passwords" {
  description = "Map of registry token usernames to generated passwords"
  value       = module.registry.user_passwords
  sensitive   = true
}

*/

output "storage_object_ids" {
  description = "Map af storage account-navn til ID"
  value       = { for k, m in module.storage_object : k => m.storage_id }
}

output "storage_object_names" {
  description = "Map af storage account-navn til oprettet navn"
  value       = { for k, m in module.storage_object : k => m.storage_name }
}

output "storage_object_connection_strings" {
  description = "Map af storage account-navn til primary connection string"
  value       = { for k, m in module.storage_object : k => m.connection_string }
  sensitive   = true
}

output "service_cluster_id" {
  description = "ID of the service Kubernetes cluster"
  value       = module.service_cluster.cluster_id
}

output "service_cluster_kubeconfig" {
  description = "Raw kubeconfig for the service cluster — pipe to a file or use with KUBECONFIG env var"
  value       = module.service_cluster.kubeconfig
  sensitive   = true
}

output "utility_cluster_id" {
  description = "ID of the utility Kubernetes cluster"
  value       = module.utility_cluster.cluster_id
}

output "utility_cluster_kubeconfig" {
  description = "Raw kubeconfig for the utility cluster — pipe to a file or use with KUBECONFIG env var"
  value       = module.utility_cluster.kubeconfig
  sensitive   = true
}
