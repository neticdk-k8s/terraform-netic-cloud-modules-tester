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

  # Fælles cloud settings for begge OVH-clustere
  ovh_cloud_settings = {
    region          = var.cloud_settings.region
    ip_restrictions = var.cloud_settings.ip_restrictions

    ovh = {
      project_id         = var.cloud_settings.ovh.project_id
      private_network_id = var.cloud_settings.network_id
    }
  }
}

# =============================================================================
# Network — OVH private vRack network
# Udkommenteret: clusterne kører uden privat netværk (private_network_id = null),
# så netværket stod bare ubrugt. Kobl module.network.network_id på
# local.ovh_cloud_settings når clusterne skal på vRack.
# =============================================================================
/*
module "network" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/network/network/wrapper"

  network = {
    name = var.network_config.name

    ovh = {
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
    }
  }
}
*/

# =============================================================================
# Kubernetes — OVH Kubernetes Service Cluster
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

  cloud_settings = local.ovh_cloud_settings
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
# Storage — OVH Object Storage
# Ét bucket pr. navn i var.storage_config.names (k8s-mimir-tbr, k8s-tempo-tbr,
# k8s-loki-tbr). for_each gør hver instans adresserbar på sit navn.
# =============================================================================
module "storage_object" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/storage/object/wrapper"

  for_each = toset(var.storage_config.names)

  storage = {
    name = each.value

    ovh = {
      project_id       = var.cloud_settings.ovh.project_id
      region           = var.storage_config.ovh.region
      versioning       = var.storage_config.ovh.versioning
      encryption_sse   = var.storage_config.ovh.encryption_sse
      object_lock_days = var.storage_config.ovh.object_lock_days
    }
  }
}

# =============================================================================
# Storage access — dedikeret bruger + S3-nøgler med adgang til de tre buckets
# Nøglerne eksponeres som outputs og hentes af workflowet (kun til test).
# =============================================================================
resource "ovh_cloud_project_user" "storage" {
  service_name = var.cloud_settings.ovh.project_id
  description  = "TF-managed storage access (mimir/tempo/loki)"
  role_names   = ["objectstore_operator"]
}

resource "ovh_cloud_project_user_s3_credential" "storage" {
  service_name = var.cloud_settings.ovh.project_id
  user_id      = ovh_cloud_project_user.storage.id
}

# Begræns brugeren til netop de tre buckets
resource "ovh_cloud_project_user_s3_policy" "storage" {
  service_name = var.cloud_settings.ovh.project_id
  user_id      = ovh_cloud_project_user.storage.id

  policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket", "s3:GetBucketLocation"]
      Resource = flatten([
        for n in var.storage_config.names : [
          "arn:aws:s3:::${n}",
          "arn:aws:s3:::${n}/*",
        ]
      ])
    }]
  })
}

# =============================================================================
# Kubernetes — OVH Kubernetes Utility Cluster
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

  cloud_settings = local.ovh_cloud_settings
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

