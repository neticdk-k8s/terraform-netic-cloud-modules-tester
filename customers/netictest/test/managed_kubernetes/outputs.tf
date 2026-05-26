output "k8s_cluster_id" {
  description = "ID på det oprettede Kubernetes cluster (returnerer null hvis deploy = false)"
  value       = one(module.k8s_cluster[*].cluster_id)
}

output "k8s_cluster_name" {
  description = "Navnet på det oprettede Kubernetes cluster"
  value       = one(module.k8s_cluster[*].cluster_name)
}

output "k8s_kubeconfig" {
  description = "Den rå kubeconfig fil til at forbinde til klyngen via kubectl"
  value       = one(module.k8s_cluster[*].kubeconfig)
  sensitive   = true # Markeres som sensitive for at skjule certifikater i GitHub logs
}