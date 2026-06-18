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
    name          = "vnet-k8s-simpel"
    address_space = ["10.0.16.0/22"]
    subnets = {
      aks     = { cidr = "10.0.16.0/24" }
      default = { cidr = "10.0.17.0/24" }
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
    name             = string
    replication_type = optional(string, "LRS")
    versioning       = optional(bool, true)
    retention_days   = optional(number, 7)
    container_name   = optional(string, "data")
  })
  description = "Azure Blob Storage konfiguration — navn skal være globalt unikt, 3-24 lowercase alfanumeriske tegn"
  default = {
    name             = "neticteststg001"
    replication_type = "LRS"
    versioning       = true
    retention_days   = 7
    container_name   = "data"
  }
}

variable "gitops_config" {
  type = object({
    cluster_repo   = string
    bootstrap_path = string
  })
  description = "GitOps / Flux bootstrap repository"
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
    "module"      = "Test_K8S_Simpel_Azure"
  }
}

variable "cluster_config" {
  type = object({
    cluster_name = string
    k8s_version  = optional(string, "1.34")
    tags         = optional(map(string), {})
  })
  description = "AKS cluster metadata"
  default = {
    cluster_name = "aks-k8s-simpel"
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
    anti_affinity      = optional(bool, false)
    labels             = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  })
  description = "AKS nodepool konfiguration"
  default = {
    node_size          = "medium"
    node_count         = 1
    min_count          = 1
    max_count          = 3
    autoscale_enabled  = false
    availability_zones = ["1", "2", "3"]
    labels             = { "role" = "stateless-apps" }
  }
}
