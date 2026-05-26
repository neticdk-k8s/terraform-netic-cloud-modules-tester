# Create an OVHcloud Managed Kubernetes cluster
resource "ovh_cloud_project_kube" "kube_cluster" {
  service_name = var.ovh_project_id
  name         = var.kube_cluster.name
  region       = var.ovh_region
  version      = var.kube_cluster.version
}

# Create a Node Pool for our Kubernetes cluster
resource "ovh_cloud_project_kube_nodepool" "node_pool" {
  service_name  = var.ovh_project_id
  kube_id       = ovh_cloud_project_kube.kube_cluster.id
  name          = var.kube_cluster.name
  flavor_name   = var.kube_cluster.size
  desired_nodes = var.kube_cluster.nodes_count
  min_nodes     = var.kube_cluster.nodes_min
  max_nodes     = var.kube_cluster.nodes_max

  template {
    metadata {
      annotations = {
        managed-by = "terraform"
      }
      finalizers = []
      labels     = var.kube_cluster.labels
    }
    spec {
      unschedulable = false
      taints        = var.kube_cluster.taints
    }
  }
}

# Kube-API IP Access restrictions
resource "ovh_cloud_project_kube_iprestrictions" "restrictions" {
  count        = length(var.kube_cluster.ip_restrictions) > 0 ? 1 : 0
  service_name = var.ovh_project_id
  kube_id      = ovh_cloud_project_kube.kube_cluster.id
  ips          = var.kube_cluster.ip_restrictions
}