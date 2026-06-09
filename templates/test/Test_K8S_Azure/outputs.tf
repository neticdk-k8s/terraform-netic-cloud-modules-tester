output "network_id" {
  description = "ID på det oprettede VNet"
  value       = module.network.network_id
}

output "subnet_ids" {
  description = "Map af subnet-navne til subnet-IDs"
  value       = module.network.subnet_ids
}

output "registry_url" {
  description = "Login-URL til Azure Container Registry"
  value       = module.registry.registry_url
}

output "registry_user_passwords" {
  description = "Genererede passwords til registry-brugere"
  value       = module.registry.user_passwords
  sensitive   = true
}

output "storage_object_name" {
  description = "Navn på storage account"
  value       = module.storage_object.storage_name
}

output "storage_object_connection_string" {
  description = "Connection string til blob storage"
  value       = module.storage_object.connection_string
  sensitive   = true
}

output "cluster_id" {
  description = "ID på AKS-clusteret"
  value       = module.kubernetes.cluster_id
}

# terraform output -raw kubeconfig > ~/.kube/config
output "kubeconfig" {
  description = "Raw kubeconfig — pipe til fil eller brug KUBECONFIG env var"
  value       = module.kubernetes.kubeconfig
  sensitive   = true
}
