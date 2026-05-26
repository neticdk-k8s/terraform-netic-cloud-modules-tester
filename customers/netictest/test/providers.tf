# Defines which plugins to load

terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.1.0"
    }

    tls = {
      source = "hashicorp/tls"
    }

    local = {
      source = "hashicorp/local"
    }
    
  }
}

provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3"
  domain_name = "Default"

  tenant_id = var.ovh_project_id
  region    = var.ovh_region
  user_name = var.OS_username
  password  = var.OS_password
}

provider "ovh" {
  endpoint = var.ovh_api_region
}