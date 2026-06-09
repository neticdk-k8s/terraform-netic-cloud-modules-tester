
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
# Container Registry — Azure Container Registry (ACR)
# =============================================================================
module "registry" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/container_registry/wrapper"

  cloud_provider = "azure"

  container_registry = {
    deploy = var.registry_config.deploy
    name   = var.registry_config.name
  }

  azure_config = {
    location       = var.cloud_settings.region
    resource_group = var.cloud_settings.azure.resource_group
    sku            = var.registry_config.sku
  }

  registry_users = [
    { login = "ci-user", email = var.registry_config.user_email }
  ]

  ip_restrictions = [
    for ip in var.cloud_settings.ip_restrictions : {
      ip_block    = ip
      description = "Allowed IP"
    }
  ]
}


# =============================================================================
# Kubernetes — Azure Kubernetes Service (AKS)
# =============================================================================
module "kubernetes" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/kubernetes/wrapper"

  cluster_config = {
    cluster_name = var.cluster_config.cluster_name
    k8s_version  = var.cluster_config.k8s_version
    tags         = merge(var.tags, var.cluster_config.tags)
  }

  node_config = {
    node_size          = var.node_config.node_size
    node_count         = var.node_config.node_count
    autoscale_enabled  = var.node_config.autoscale_enabled
    min_count          = var.node_config.min_count
    max_count          = var.node_config.max_count
    availability_zones = var.node_config.availability_zones
    k8s_version        = coalesce(var.node_config.k8s_version, var.cluster_config.k8s_version)
    monthly_billed     = var.node_config.monthly_billed
    anti_affinity      = var.node_config.anti_affinity
    labels             = var.node_config.labels
    taints             = var.node_config.taints
  }

  cloud_settings = {
    cloud_provider     = "azure"
    region             = var.cloud_settings.region
    project_identifier = var.cloud_settings.azure.resource_group
    network_id         = module.network.subnet_ids["aks"]
    azure_dns_prefix   = var.cloud_settings.azure.dns_prefix
    ip_restrictions    = var.cloud_settings.ip_restrictions
  }
}


# =============================================================================
# Storage — Azure Blob Storage
# =============================================================================
module "storage_object" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/storage/object/wrapper"

  cloud_provider = "azure"
  name           = var.storage_config.name

  azure = {
    resource_group   = var.cloud_settings.azure.resource_group
    location         = var.cloud_settings.region
    replication_type = var.storage_config.replication_type
    versioning       = var.storage_config.versioning
    retention_days   = var.storage_config.retention_days
    container_name   = var.storage_config.container_name
  }
}


# =============================================================================
# GitOps / Flux Bootstrap
# =============================================================================
module "flux_bootstrap" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/kubernetes/bootstrap/gitops"

  kubeconfig = module.kubernetes.kubeconfig

  cluster_repo   = var.gitops_config.cluster_repo
  bootstrap_path = var.gitops_config.bootstrap_path

  git_auth = {
    netic = {
      username = var.netic_git_username
      password = var.netic_git_token
    }
    "kubernetes-config" = {
      identity = var.gitops_ssh_key
    }
  }
}


# =============================================================================
# Role Assignment — AKS service principal adgang til VNet subnet
# =============================================================================
resource "azurerm_role_assignment" "aks_network" {
  scope                = module.network.subnet_ids["aks"]
  role_definition_name = "Network Contributor"
  principal_id         = module.kubernetes.cluster_identity_id
}
