// Best way is to deploy a OVHCloud Connect (like epressroute) to fx 

// OCC Direct - Germany - Equinox FR-5
// Expressroute til FR-5

// https://www.ovhcloud.com/en/network/ovhcloud-connect/
// https://docs.ovhcloud.com/en/guides/network/ovhcloud-connect/occ-provider-control-panel
module "network" {
  source = "../../../../modules/network"
  ovh_project_id = var.ovh_project_id
  network_name   = "${var.name_prefix}-${var.network.name}-${var.environment}"
  vlan_id        = var.network.vlan
  regions        = var.network.regions
}


module "vpnvm" {
  source = "../../../../modules/vm"
  vm = var.vpn_vm
  depends_on = [ module.network ]
}


// Activate ip-forwarding on vm 
//   net.ipv4.ip_forward = 1
