
# =============================================================================
# Network — OVH private vRack network
# =============================================================================
module "network" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/network/network/wrapper"

  network = {
    name = var.network_config.name

    ovh = var.cloud_settings.cloud_provider == "ovh" ? {
      project_id = var.cloud_settings.ovh.project_id
      vlan_id    = var.network_config.ovh.vlan_id
      regions = [
        for r in var.network_config.ovh.regions : {
          region              = r.region
          subnet              = r.subnet
          dhcp                = r.dhcp
          no_gateway          = var.network_config.ovh.no_gateway
          ip_allocation_start = coalesce(r.ip_allocation_start, 10)
          ip_allocation_stop  = coalesce(r.ip_allocation_stop, 200)
        }
      ]
    } : null

    azure = var.cloud_settings.cloud_provider == "azure" ? {
      location       = var.cloud_settings.region
      resource_group = var.cloud_settings.azure.resource_group
      address_space  = var.network_config.azure.address_space
      subnets        = var.network_config.azure.subnets
    } : null
  }
}


# =============================================================================
# Container Registry
# =============================================================================
module "registry" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/container_registry/wrapper"

  cloud_provider = var.cloud_settings.cloud_provider

  container_registry = {
    deploy = var.registry_config.deploy
    name   = var.registry_config.name
  }

  azure_config = var.cloud_settings.cloud_provider == "azure" ? {
    location       = var.cloud_settings.region
    resource_group = var.cloud_settings.azure.resource_group
    sku            = try(var.registry_config.azure.sku, "Standard")
  } : null

  ovh_config = var.cloud_settings.cloud_provider == "ovh" ? {
    project_id = var.cloud_settings.ovh.project_id
    region     = var.registry_config.ovh.region
  } : null

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
# Kubernetes Cluster
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
    cloud_provider     = var.cloud_settings.cloud_provider
    region             = var.cloud_settings.region
    project_identifier = var.cloud_settings.cloud_provider == "azure" ? var.cloud_settings.azure.resource_group : var.cloud_settings.ovh.project_id
    network_id         = var.cloud_settings.cloud_provider == "azure" ? module.network.subnet_ids["aks"] : var.cloud_settings.network_id
    azure_dns_prefix   = try(var.cloud_settings.azure.dns_prefix, null)
    ip_restrictions    = var.cloud_settings.ip_restrictions
  }
}

# =============================================================================
# Storage — Object
# =============================================================================
module "storage_object" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/storage/object/wrapper"

  cloud_provider = var.cloud_settings.cloud_provider
  name           = var.storage_config.name

  ovh = var.cloud_settings.cloud_provider == "ovh" ? {
    project_id       = var.cloud_settings.ovh.project_id
    region           = try(var.storage_config.ovh.region, "GRA")
    versioning       = try(var.storage_config.ovh.versioning, "enabled")
    encryption_sse   = try(var.storage_config.ovh.encryption_sse, "AES256")
    object_lock_days = try(var.storage_config.ovh.object_lock_days, 0)
  } : null

  azure = var.cloud_settings.cloud_provider == "azure" ? {
    resource_group   = var.cloud_settings.azure.resource_group
    location         = var.cloud_settings.region
    replication_type = try(var.storage_config.azure.replication_type, "LRS")
    versioning       = try(var.storage_config.azure.versioning, true)
    retention_days   = try(var.storage_config.azure.retention_days, 7)
    container_name   = try(var.storage_config.azure.container_name, "data")
  } : null
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
# Role Assignments (Azure only)
# =============================================================================
resource "azurerm_role_assignment" "aks_network" {
  count                = var.cloud_settings.cloud_provider == "azure" ? 1 : 0
  scope                = module.network.subnet_ids["aks"]
  role_definition_name = "Network Contributor"
  principal_id         = module.kubernetes.cluster_identity_id
}
