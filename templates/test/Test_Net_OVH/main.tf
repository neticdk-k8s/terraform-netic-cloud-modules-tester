
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
