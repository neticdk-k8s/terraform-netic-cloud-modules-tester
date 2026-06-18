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
  description = "OVH API endpoint"
  default     = "ovh-eu"
}

variable "cloud_settings" {
  type = object({
    region = string
    ovh = object({
      project_id = string
    })
    network_id      = optional(string, null)
    ip_restrictions = optional(list(string), [])
  })
  description = "OVH cloud settings — region, projekt ID og netværk"
  default = {
    region = "UK1"
    ovh = {
      project_id = "bb219a2fd02c487798bbb0b349f622a5"
    }
    network_id      = null
    ip_restrictions = []
  }
}

variable "network_config" {
  type = object({
    name = optional(string, "vnet-netic-test-ovh")
    ovh = object({
      vlan_id    = number
      no_gateway = optional(bool, false)
      regions = list(object({
        region              = string
        subnet              = string
        dhcp                = bool
        ip_allocation_start = optional(number, 10)
        ip_allocation_stop  = optional(number, 200)
      }))
    })
  })
  description = "OVH vRack network konfiguration"
  default = {
    name = "vnet-netic-test-ovh"
    ovh = {
      vlan_id    = 110
      no_gateway = false
      regions = [
        {
          region = "UK1"
          subnet = "10.0.12.0/24"
          dhcp   = true
        }
      ]
    }
  }
}

variable "registry_config" {
  type = object({
    deploy = bool
    name   = string
    ovh = object({
      region = optional(string, "UK1")
    })
    user_email = optional(string, "ci@example.com")
  })
  description = "OVH Container Registry konfiguration"
  default = {
    deploy = true
    name   = "netictest-ovh"
    ovh = {
      region = "GRA"
    }
    user_email = "ci@example.com"
  }
}

variable "storage_config" {
  type = object({
    names = list(string)
    ovh = object({
      region           = optional(string, "UK1")
      versioning       = optional(string, "enabled")
      encryption_sse   = optional(string, "AES256")
      object_lock_days = optional(number, 0)
    })
  })
  description = "OVH Object Storage konfiguration — ét bucket pr. navn i names"
  default = {
    names = ["k8s_mimir_tbr", "k8s_tempo_tbr", "k8s_loki_tbr"]
    ovh = {
      region           = "UK1"
      versioning       = "enabled"
      encryption_sse   = "AES256"
      object_lock_days = 0
    }
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
    "module"      = "Test_K8S_OVH"
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
  description = "Service cluster — OVH Kubernetes metadata, nodepool og kubernetes-config repo"
  default = {
    cluster_config = {
      cluster_name = "k8s-netic-services-test"
      tags = {
        "owner"       = "team-azure"
        "cost_center" = "test-ops"
      }
    }
    node_config = {
      node_size          = "test-medium"
      node_count         = 2
      min_count          = 1
      max_count          = 5
      autoscale_enabled  = false
      availability_zones = []
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
  description = "Utility cluster — OVH Kubernetes metadata, nodepool og kubernetes-config repo"
  default = {
    cluster_config = {
      cluster_name = "k8s-netic-utility-test"
      tags = {
        "owner"       = "team-azure"
        "cost_center" = "test-ops"
      }
    }
    node_config = {
      node_size          = "test-medium"
      node_count         = 1
      min_count          = 1
      max_count          = 5
      autoscale_enabled  = false
      availability_zones = []
      labels             = { "role" = "stateless-apps" }
    }
    kubernetes_config = {
      cluster_repo   = "git.netic.dk/scm/kub/ovh-kubernetes-config.git"
      bootstrap_path = "clusters/netic-platform-ovh/netic-k8s-test/bootstrap/"
    }
  }
}
