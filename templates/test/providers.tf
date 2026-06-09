terraform {
  required_version = ">= 1.5"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.1.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

# Authenticates via env vars: OVH_APPLICATION_KEY, OVH_APPLICATION_SECRET, OVH_CONSUMER_KEY
provider "ovh" {
  endpoint = var.ovh_api_region
}

# Authenticates via env vars: OS_USERNAME, OS_PASSWORD
provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3"
  domain_name = "Default"
  tenant_id   = var.cloud_settings.ovh != null ? var.cloud_settings.ovh.project_id : ""
  region      = var.cloud_settings.region
}

# Required by module wrappers (azure path) — no resources created on OVH deployments
provider "azurerm" {
  features {}
  subscription_id                 = try(var.cloud_settings.azure.subscription_id, "")
  resource_provider_registrations = "none"
  use_cli                         = false
}
