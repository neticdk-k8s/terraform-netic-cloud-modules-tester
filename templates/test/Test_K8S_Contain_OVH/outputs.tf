
# Netværksmodulet er udkommenteret i main.tf — gen-aktiver outputs sammen med det
/*
output "network_id" {
  description = "ID of the private vRack network"
  value       = module.network.network_id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.network.subnet_ids
}
*/

output "storage_object_id" {
  description = "ID of the object storage resource"
  value       = module.storage_object.storage_id
}

output "storage_object_name" {
  description = "Name of the object storage resource"
  value       = module.storage_object.storage_name
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


# tofu output -raw service_cluster_kubeconfig > ~/.kube/ovhs.yaml
# tofu output -raw utility_cluster_kubeconfig > ~/.kube/ovhu.yaml
# k9s --kubeconfig ~/.kube/ovhs.yaml
#evt cp ~/.kube/ovhs.yaml ~/.kube/config       