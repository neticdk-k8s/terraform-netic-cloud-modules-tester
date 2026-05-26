output "cluster_id" {
  description = "The ID of the Kubernetes cluster"
  value       = ovh_cloud_project_kube.kube_cluster.id
}

output "cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = ovh_cloud_project_kube.kube_cluster.name
}

output "kubeconfig" {
  description = "The raw kubeconfig to connect to the cluster"
  value       = ovh_cloud_project_kube.kube_cluster.kubeconfig
  sensitive   = true
}