# =============================================================================
# Locals — fælles værdier der genbruges på tværs af modulerne
# =============================================================================
locals {
  git_auth = {
    netic = {
      username = var.netic_git_username
      password = var.netic_git_token
    }
    "kubernetes-config" = {
      identity = var.gitops_ssh_key
    }
  }

  # Fælles cloud settings for begge AKS-clustere — skal være en local,
  # da subnet_id refererer til et modul-output
  aks_cloud_settings = {
    region          = var.cloud_settings.region
    ip_restrictions = var.cloud_settings.ip_restrictions

    azure = {
      resource_group = var.cloud_settings.azure.resource_group
      subnet_id      = module.network.subnet_ids["aks"]
      dns_prefix     = var.cloud_settings.azure.dns_prefix
    }
  }
}

# =============================================================================
# Network — Azure VNet med subnets og NSGs
# =============================================================================
module "network" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/network/network/wrapper"

  network = {
    name = var.network_config.name

    azure = {
      location       = var.cloud_settings.region
      resource_group = var.cloud_settings.azure.resource_group
      address_space  = var.network_config.address_space
      subnets        = var.network_config.subnets
    }
  }
}

# =============================================================================
# Kubernetes — Azure Kubernetes Service (AKS)   Service Cluster
# =============================================================================
module "service_cluster" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/kubernetes/wrapper"

  cluster_config = {
    cluster_name = var.service_cluster.cluster_config.cluster_name
    k8s_version  = var.service_cluster.cluster_config.k8s_version
    tags         = merge(var.tags, var.service_cluster.cluster_config.tags)
  }

  node_config = merge(var.service_cluster.node_config, {
    k8s_version = coalesce(var.service_cluster.node_config.k8s_version, var.service_cluster.cluster_config.k8s_version)
  })

  cloud_settings = local.aks_cloud_settings
}

# Bootstrap Service Cluster with flux
module "service_cluster_flux_bootstrap" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/kubernetes/bootstrap/gitops"

  kubeconfig = module.service_cluster.kubeconfig

  cluster_repo   = var.flux_bootstrap.cluster_repo
  bootstrap_path = var.flux_bootstrap.bootstrap_path

  git_auth = local.git_auth
}

# Bootstrap Service Cluster with git.netic.dk kubernetes-config
module "service_cluster_kubernetes_config" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/kubernetes/bootstrap/gitops"

  kubeconfig     = module.service_cluster.kubeconfig
  cluster_repo   = var.service_cluster.kubernetes_config.cluster_repo
  bootstrap_path = var.service_cluster.kubernetes_config.bootstrap_path

  git_auth = local.git_auth

  depends_on = [module.service_cluster_flux_bootstrap]
}

# =============================================================================
# Storage — Azure Blob Storage
# Ét storage account pr. navn i var.storage_config.names (k8smimirtbr,
# k8stempotbr, k8slokitbr). for_each gør hver instans adresserbar på sit navn.
# Azure storage account-navne skal være globalt unikke, så der hægtes et
# tilfældigt suffiks på hvert navn (lowercase alfanumerisk, samlet ≤ 24 tegn).
# =============================================================================
resource "random_string" "storage_suffix" {
  for_each = toset(var.storage_config.names)

  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

module "storage_object" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/storage/object/wrapper"

  for_each = toset(var.storage_config.names)

  storage = {
    name = "${each.value}${random_string.storage_suffix[each.key].result}"

    azure = {
      resource_group   = var.cloud_settings.azure.resource_group
      location         = var.cloud_settings.region
      replication_type = var.storage_config.replication_type
      versioning       = var.storage_config.versioning
      retention_days   = var.storage_config.retention_days
      container_name   = var.storage_config.container_name
    }
  }
}

# =============================================================================
# Kubernetes — Azure Kubernetes Service (AKS)   Utility Cluster
# =============================================================================
module "utility_cluster" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/kubernetes/wrapper"

  cluster_config = {
    cluster_name = var.utility_cluster.cluster_config.cluster_name
    k8s_version  = var.utility_cluster.cluster_config.k8s_version
    tags         = merge(var.tags, var.utility_cluster.cluster_config.tags)
  }

  node_config = merge(var.utility_cluster.node_config, {
    k8s_version = coalesce(var.utility_cluster.node_config.k8s_version, var.utility_cluster.cluster_config.k8s_version)
  })

  cloud_settings = local.aks_cloud_settings
}

# Bootstrap Utility Cluster with flux
module "utility_cluster_flux_bootstrap" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/kubernetes/bootstrap/gitops"

  kubeconfig = module.utility_cluster.kubeconfig

  cluster_repo   = var.flux_bootstrap.cluster_repo
  bootstrap_path = var.flux_bootstrap.bootstrap_path

  git_auth = local.git_auth
}

# Bootstrap Utility Cluster with git.netic.dk kubernetes-config
module "utility_cluster_kubernetes_config" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/kubernetes/bootstrap/gitops"

  kubeconfig     = module.utility_cluster.kubeconfig
  cluster_repo   = var.utility_cluster.kubernetes_config.cluster_repo
  bootstrap_path = var.utility_cluster.kubernetes_config.bootstrap_path

  git_auth = local.git_auth

  depends_on = [module.utility_cluster_flux_bootstrap]
}

# =============================================================================
# Role Assignments
# =============================================================================
resource "azurerm_role_assignment" "service_cluster_network" {
  scope                = module.network.subnet_ids["aks"]
  role_definition_name = "Network Contributor"
  principal_id         = module.service_cluster.cluster_identity_id
}

resource "azurerm_role_assignment" "utility_cluster_network" {
  scope                = module.network.subnet_ids["aks"]
  role_definition_name = "Network Contributor"
  principal_id         = module.utility_cluster.cluster_identity_id
}
