module "k8s_cluster" {
  source = "../../../../modules/kubernetes"
  
  # BEST PRACTICE: Hvis deploy er false, oprettes intet i modulet. Rent og pænt!
  count = var.ManagedKMSCluster.deploy ? 1 : 0

  ovh_project_id = var.ovh_project_id
  ovh_region     = var.ovh_region
  kube_cluster   = var.ManagedKMSCluster
}
