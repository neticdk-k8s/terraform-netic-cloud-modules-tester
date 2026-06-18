# =============================================================================
# GitOps / Flux credentials (set via TF_VAR_* environment variables)
# =============================================================================
variable "netic_git_username" {
  type        = string
  sensitive   = true
  description = "Username for git.netic.dk (gotk-bootstrap-k8s repo)"
}

variable "netic_git_token" {
  type        = string
  sensitive   = true
  description = "Password / token for git.netic.dk"
}

# ssh-keygen -t ed25519 -C "flux@netic-k8s-test" -f ./flux-deploy-key -N ""
# export TF_VAR_gitops_ssh_key="$(cat ./flux-deploy-key)"
variable "gitops_ssh_key" {
  type        = string
  sensitive   = true
  description = "Private SSH key for the kubernetes-config repo (GitHub)"
  default     = ""
}

variable "ovh_api_region" {
  type        = string
  description = "OVH API endpoint region (e.g., 'ovh-eu', 'ovh-ca')"
  default     = "ovh-eu"
}

variable "registry_config" {
  type = object({
    deploy     = bool
    name       = string
    user_email = optional(string, "ci@example.com")
    azure = optional(object({
      sku = optional(string, "Standard")
    }), null)
    ovh = optional(object({
      region = string
    }), null)
  })
  description = "Container registry configuration"
  default = {
    deploy     = true
    name       = "registry-tbr"
    user_email = "ci@example.com"
    azure      = { sku = "Standard" }
    ovh        = { region = "DE" }
  }
}

variable "storage_config" {
  type = object({
    name = string
    azure = optional(object({
      replication_type = optional(string, "LRS")
      versioning       = optional(bool, true)
      retention_days   = optional(number, 7)
      container_name   = optional(string, "data")
    }), null)
    ovh = optional(object({
      region           = optional(string, "GRA")
      versioning       = optional(string, "enabled")
      encryption_sse   = optional(string, "AES256")
      object_lock_days = optional(number, 0)
    }), null)
  })
  description = "Object storage configuration"
  default = {
    name  = "tbrteststorage12312312"
    azure = { replication_type = "LRS", versioning = true, retention_days = 7, container_name = "data" }
    ovh   = { region = "GRA" }
  }
}

variable "gitops_config" {
  type = object({
    cluster_repo   = string
    bootstrap_path = string
  })
  description = "GitOps / Flux bootstrap repository settings"
  default = {
    cluster_repo   = "git.netic.dk/scm/pd/gotk-bootstrap-k8s.git"
    bootstrap_path = "gotk"
  }
}

variable "tags" {
  type        = map(string)
  description = "Global tags applied to all resources"
  default = {
    "owner"       = "team-cn"
    "environment" = "testing"
    "managed-by"  = "terraform"
    "module"      = "Test_K8s_OVH"
  }
}

variable "cluster_config" {
  type = object({
    cluster_name = string
    k8s_version  = optional(string, "1.34")
    tags         = optional(map(string), {})
  })
  description = "General cluster metadata and tagging"
  default = {
    cluster_name = "vnet_k8s_simpel"
    tags = {
      "owner"       = "team-cn"
      "cost_center" = "test-ops"
    }
  }
}

variable "node_config" {
  type = object({
    node_size          = string
    node_count         = number
    autoscale_enabled  = bool
    min_count          = optional(number, null)
    max_count          = optional(number, null)
    availability_zones = optional(list(string), [])
    k8s_version        = optional(string, null)
    monthly_billed     = optional(bool, false)
    anti_affinity      = optional(bool, true)
    labels             = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  })
  description = "Sizing, scaling, and labeling for the default node pool"
  default = {
    node_size         = "medium"
    node_count        = 1
    min_count         = 1
    max_count         = 2
    autoscale_enabled = false
    labels            = { "role" = "stateless-apps" }
  }
}

variable "network_config" {
  type = object({
    name = optional(string, "network")
    azure = optional(object({
      address_space = list(string)
      subnets       = map(object({ cidr = string }))
    }), null)
    ovh = optional(object({
      vlan_id    = number
      no_gateway = optional(bool, false)
      regions = list(object({
        region              = string
        subnet              = string
        dhcp                = optional(bool, true)
        ip_allocation_start = optional(number, null)
        ip_allocation_stop  = optional(number, null)
      }))
    }), null)
  })
  description = "Network configuration"
  default = {
    name = "vnet_k8s_simpel"

    ovh = {
      vlan_id    = 100
      no_gateway = false
      regions = [{
        region = "GRA9"
        subnet = "10.0.1.0/24"
        dhcp   = true
      }]
    }
  }
}

variable "cloud_settings" {
  type = object({
    cloud_provider = string
    region         = string
    azure = optional(object({
      subscription_id = string
      resource_group  = string
      dns_prefix      = optional(string, null)
    }), null)
    ovh = optional(object({
      project_id = string
    }), null)
    network_id      = optional(string, null)
    ip_restrictions = optional(list(string), [])
  })
  description = "Cloud provider landing zone configuration"
  default = {
    cloud_provider = "ovh"
    region         = "GRA9"
    ovh = {
      project_id = "bb219a2fd02c487798bbb0b349f622a5"
    }
    network_id      = null
    ip_restrictions = []
    /*  The above does not work from github.  
        private runner with static IPs and allowlist is required.
      "77.243.59.220/32",
      "185.29.76.1/32",
      "185.29.76.2/32",
      "20.126.188.216/32",
      "20.23.62.36/32",
      "185.181.22.4/32",
      "4.205.250.156/32",
      "212.169.216.3/32",
      "185.181.22.18/32",
      "46.27.142.96/32"
    ]
    */
  }
}
