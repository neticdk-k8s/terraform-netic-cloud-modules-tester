# Define providers and set versions
terraform {
required_version    = ">= 0.14.0" 
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 3.0.0"
    }

    ovh = {
      source  = "ovh/ovh"
      version = ">= 2.1.0"
    }
    
    // For SSL
    tls = {
      source = "hashicorp/tls"
    }

    local = {
      source = "hashicorp/local"
    }
  }
  backend "s3" {
    bucket   = "tf-state-netictest-test2" 
    key      = "terraform.tfstate"
    region   = "bhs"                  # Din region i små bogstaver (f.eks. gra, sbg, waw)
     endpoints = {
      s3 = "https://s3.bhs.io.cloud.ovh.net"
    }
    # Vitale indstillinger når man bruger S3-backenden uden for AWS:
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }

}

provider "openstack" {
  auth_url    = "https://auth.cloud.ovh.net/v3"
  domain_name = "Default"

  tenant_id   = var.ovh_project_id 
  region      = var.storage.region
}

provider "ovh" {
  endpoint           = var.ovh_api_region
}