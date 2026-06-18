
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
output "storage_object_ids" {
  description = "Map af bucket-navn til storage ID"
  value       = { for k, m in module.storage_object : k => m.storage_id }
}

output "storage_object_names" {
  description = "Map af bucket-navn til oprettet storage-navn"
  value       = { for k, m in module.storage_object : k => m.storage_name }
}

output "storage_s3_access_key" {
  description = "S3 access key id for storage-brugeren (adgang til de tre buckets)"
  value       = ovh_cloud_project_user_s3_credential.storage.access_key_id
}

output "storage_s3_secret_key" {
  description = "S3 secret access key for storage-brugeren"
  value       = ovh_cloud_project_user_s3_credential.storage.secret_access_key
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

# tofu output -raw service_cluster_kubeconfig > ~/.kube/ovhs.yaml
# tofu output -raw utility_cluster_kubeconfig > ~/.kube/ovhu.yaml
# k9s --kubeconfig ~/.kube/ovhs.yaml
#evt cp ~/.kube/ovhs.yaml ~/.kube/config       