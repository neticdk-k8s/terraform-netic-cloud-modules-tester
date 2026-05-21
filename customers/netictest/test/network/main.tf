module "network" {
  source = "../../../../modules/network"
  ovh_project_id = var.ovh_project_id
  network_name   = var.network.name
  vlan_id        = var.network.vlan
  regions        = var.network.regions
}

