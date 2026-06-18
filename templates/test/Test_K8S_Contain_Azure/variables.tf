# =============================================================================
# GitOps / Flux credentials (sættes via TF_VAR_* env vars)
# =============================================================================
variable "netic_git_username" {
  type        = string
  sensitive   = true
  description = "Brugernavn til git.netic.dk"
}

variable "netic_git_token" {
  type        = string
  sensitive   = true
  description = "Token til git.netic.dk"
}

variable "gitops_ssh_key" {
  type        = string
  sensitive   = true
  description = "Privat SSH-nøgle til kubernetes-config repo"
  default     = ""
}

variable "ovh_api_region" {
  type        = string
  description = "OVH API endpoint — påkrævet af delt providers.tf"
  default     = "ovh-eu"
}

variable "cloud_settings" {
  type = object({
    region = string
    ovh    = optional(object({ project_id = string }), null)
    azure = optional(object({
      subscription_id = string
      resource_group  = string
      dns_prefix      = optional(string, null)
    }), null)
    network_id      = optional(string, null)
    ip_restrictions = optional(list(string), [])
  })
  description = "Azure region, resource group og adgangsstyring"
  default = {
    region = "denmarkeast"
    azure = {
      subscription_id = "9cbb71c9-7f62-4277-a708-f89d1f020134"
      resource_group  = "rg-tbr-test"
      dns_prefix      = "netictest"
    }
    network_id      = null
    ip_restrictions = []
  }
}

variable "network_config" {
  type = object({
    name          = optional(string, "vnet-netic-test")
    address_space = list(string)
    subnets       = map(object({ cidr = string }))
  })
  description = "Azure VNet konfiguration"
  default = {
    name          = "vnet-netic-test"
    address_space = ["10.0.12.0/22"]
    subnets = {
      aks     = { cidr = "10.0.12.0/24" }
      default = { cidr = "10.0.13.0/24" }
    }
  }
}

variable "registry_config" {
  type = object({
    deploy     = bool
    name       = string
    sku        = optional(string, "Basic")
    user_email = optional(string, "ci@example.com")
  })
  description = "Azure Container Registry konfiguration — navn skal være globalt unikt, 5-50 alfanumeriske tegn"
  default = {
    deploy     = true
    name       = "netictestreg001"
    sku        = "Basic"
    user_email = "ci@example.com"
  }
}

variable "storage_config" {
  type = object({
    names            = list(string)
    replication_type = optional(string, "LRS")
    versioning       = optional(bool, true)
    retention_days   = optional(number, 7)
    container_name   = optional(string, "data")
  })
  description = "Azure Blob Storage konfiguration — ét storage account pr. navn i names. Navne skal være globalt unikke, 3-24 lowercase alfanumeriske tegn (ingen underscores)"
  default = {
    # Azure storage account-navne tillader ikke underscores; mimir/tempo/loki i underscore-fri form
    names            = ["k8smimirtbr", "k8stempotbr", "k8slokitbr"]
    replication_type = "LRS"
    versioning       = true
    retention_days   = 7
    container_name   = "data"
  }
}

# =============================================================================
# GitOps — fælles Flux bootstrap repo (gotk), ens for alle clustere
# =============================================================================
variable "flux_bootstrap" {
  type = object({
    cluster_repo   = string
    bootstrap_path = string
  })
  description = "Fælles Flux/gotk bootstrap repository"
  default = {
    cluster_repo   = "git.netic.dk/scm/pd/gotk-bootstrap-k8s.git"
    bootstrap_path = "gotk"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags på alle ressourcer"
  default = {
    "owner"       = "team-tbr"
    "environment" = "testing"
    "managed-by"  = "terraform"
    "module"      = "Test_K8S_Azure"
  }
}

# =============================================================================
# Clustere — al per-cluster konfiguration samlet i ét objekt pr. cluster
# =============================================================================
variable "service_cluster" {
  type = object({
    cluster_config = object({
      cluster_name = string
      k8s_version  = optional(string, "1.34")
      tags         = optional(map(string), {})
    })
    node_config = object({
      node_size          = string
      node_count         = number
      autoscale_enabled  = bool
      min_count          = optional(number, null)
      max_count          = optional(number, null)
      availability_zones = optional(list(string), [])
      k8s_version        = optional(string, null)
      monthly_billed     = optional(bool, false)
      anti_affinity      = optional(bool, false)
      labels             = optional(map(string), {})
      taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })), [])
    })
    kubernetes_config = object({
      cluster_repo   = string
      bootstrap_path = string
    })
  })
  description = "Service cluster — AKS metadata, nodepool og kubernetes-config repo"
  default = {
    cluster_config = {
      cluster_name = "aks-netic-services-test"
      tags = {
        "owner"       = "team-tbr"
        "cost_center" = "test-ops"
      }
    }
    node_config = {
      node_size          = "small"
      node_count         = 2
      min_count          = 2
      max_count          = 5
      autoscale_enabled  = false
      availability_zones = ["1", "2", "3"]
      labels             = { "role" = "stateless-apps" }
    }
    kubernetes_config = {
      cluster_repo   = "git.netic.dk/scm/kub/ovh-kubernetes-config.git"
      bootstrap_path = "clusters/netic-platform-ovh/netic-k8s-services-test/bootstrap/"
    }
  }
}

variable "utility_cluster" {
  type = object({
    cluster_config = object({
      cluster_name = string
      k8s_version  = optional(string, "1.34")
      tags         = optional(map(string), {})
    })
    node_config = object({
      node_size          = string
      node_count         = number
      autoscale_enabled  = bool
      min_count          = optional(number, null)
      max_count          = optional(number, null)
      availability_zones = optional(list(string), [])
      k8s_version        = optional(string, null)
      monthly_billed     = optional(bool, false)
      anti_affinity      = optional(bool, false)
      labels             = optional(map(string), {})
      taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })), [])
    })
    kubernetes_config = object({
      cluster_repo   = string
      bootstrap_path = string
    })
  })
  description = "Utility cluster — AKS metadata, nodepool og kubernetes-config repo"
  default = {
    cluster_config = {
      cluster_name = "aks-netic-utility-test"
      tags = {
        "owner"       = "team-tbr"
        "cost_center" = "test-ops"
      }
    }
    node_config = {
      node_size          = "small"
      node_count         = 1
      min_count          = 1
      max_count          = 3
      autoscale_enabled  = false
      availability_zones = ["1", "2", "3"]
      labels             = { "role" = "stateless-apps" }
    }
    kubernetes_config = {
      cluster_repo   = "git.netic.dk/scm/kub/ovh-kubernetes-config.git"
      bootstrap_path = "clusters/netic-platform-ovh/netic-k8s-test/bootstrap/"
    }
  }
}
