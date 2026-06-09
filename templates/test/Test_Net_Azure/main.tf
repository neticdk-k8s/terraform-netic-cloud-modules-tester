
# =============================================================================
# Network — Azure VNet med subnets og NSGs
# =============================================================================
module "network" {
  source = "github.com/neticdk-k8s/terraform-netic-cloud-modules//modules/network/network/wrapper"

  network = {
    name = var.network_config.name

    azure = {
      location       = var.cloud_settings.region
      resource_group = var.cloud_settings.azure.resource_group
      address_space  = var.network_config.address_space
      subnets        = var.network_config.subnets
    }
  }
}
