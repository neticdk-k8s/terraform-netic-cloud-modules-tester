module "network" {
  source = "../../../../modules/network"
  ovh_project_id = var.ovh_project_id
  network_name   = "${var.name_prefix}-${var.network.name}-${var.environment}"
  vlan_id        = var.network.vlan
  regions        = var.network.regions
}
