
# =============================================================================
# Network — OVH private vRack network
# =============================================================================
module "network" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/network/network/wrapper"

  network = {
    name = var.network_config.name

    ovh = {
      project_id = var.cloud_settings.ovh.project_id
      vlan_id    = var.network_config.vlan_id
      regions    = var.network_config.regions
    }
  }
}

module "network2" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/network/network/wrapper"

  network = {
    name = var.network2_config.name

    ovh = {
      project_id = var.cloud_settings.ovh.project_id
      vlan_id    = var.network2_config.vlan_id
      regions    = var.network2_config.regions
    }
  }
}

/*
# =============================================================================
# Image — upload OPNsense til Glance (OVH har ikke et stock OPNsense-image)
# =============================================================================
resource "openstack_images_image_v2" "opnsense" {
  count = var.image_config.upload ? 1 : 0

  name             = var.image_config.name
  image_source_url = var.image_config.local_file_path == null ? var.image_config.source_url : null
  local_file_path  = var.image_config.local_file_path
  decompress       = var.image_config.decompress
  disk_format      = var.image_config.disk_format
  container_format = var.image_config.container_format
  min_disk_gb      = var.image_config.min_disk_gb
  visibility       = "private"

  properties = {
    os_type = "linux"
  }
}

locals {
  # Brug det uploadede image hvis vi uploader det, ellers slå op på navn (eksisterende image)
  vm_image_name = var.image_config.upload ? openstack_images_image_v2.opnsense[0].name : var.vm_config.image_name
}
*/

# =============================================================================
# VM — OPNsense firewall
# =============================================================================
module "vm" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/vm/wrapper"

  vm = {
    name             = var.vm_config.name
    size             = var.vm_config.size
    location         = var.cloud_settings.region
    resource_group   = var.vm_config.resource_group
    os_type          = "Linux"
    ssh_public_key   = var.vm_config.ssh_public_key
    create_public_ip = var.vm_config.create_public_ip

    ovh = {
      project_id      = var.cloud_settings.ovh.project_id
      image_name      = var.vm_config.image_name # skal matche det uploadede image eller et eksisterende image i OVH-projektet
      network_names   = [var.network_config.name, var.network2_config.name]
      security_groups = var.vm_config.security_groups
    }

    tags = var.tags
  }

  depends_on = [module.network, module.network2]
}
