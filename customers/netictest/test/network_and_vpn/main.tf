// Best way is to deploy a OVHCloud Connect (like expressroute) to fx 
// OCC Direct - Germany - Equinox FR-5
// Expressroute til FR-5
// https://www.ovhcloud.com/en/network/ovhcloud-connect/
// https://docs.ovhcloud.com/en/guides/network/ovhcloud-connect/occ-provider-control-panel


# 1. Definer de faste test-nøgler ét centralt sted i din main.tf (locals)
locals {
  vpn_priv = "wGq30Vf6ZkY9mX1ArB7PjD9uN2mS4vK6tL8xZ0qW3E4="
  vpn_pub  = "pQx79Wk5mN0vL2tK4vS6mD8uN2jP7ArB9mX1ZkY9mE4="

  testvm_priv = "aBC123xyzD456vFRtG789uHJkI012mNObP345qRS6tU="
  testvm_pub  = "xYZ987cbaF654vTRdG321uHJkI012mNObP345qRS6tE4="
}


# 1. Netværksmodul (vRack, subnets osv.)
module "network" {
  source         = "../../../../modules/network"
  ovh_project_id = var.ovh_project_id
  network_name   = var.network.name
  vlan_id        = var.network.vlan
  regions        = var.network.regions
}

# 2. Din VPN VM (Oprettes nu med 2 netkort og stongSwan userdata)

module "vpnvm" {
  source         = "../../../../modules/vm"
  ovh_project_id = var.ovh_project_id

  vm = merge(var.vpn_vm, {
    user_data = templatefile("${path.module}/userdata.sh.tpl", {
      ovh_subnet   = var.network.regions[0].subnet
      azure_ip     = var.azure_vpn_gateway_ip
      azure_subnet = var.azure_vnet_subnet_cidr
      azure_psk    = var.azure_vpn_secret

      # 🚀 RETTET HER: Her fødes de statiske WireGuard-nøgler til VPN Gatewayen
      vpn_private_key   = local.vpn_priv
      testvm_public_key = local.testvm_pub
    })
  })

  depends_on = [module.network]
}

# 2. Udrul din test-VM
module "testvm" {
  source         = "../../../../modules/vm"
  ovh_project_id = var.ovh_project_id

  vm = merge(var.testvm, {
    # Her mapper vi variablerne direkte til dit Bash-script:
    user_data = templatefile("${path.module}/userdata_testvm.sh.tpl", {
      azure_subnet = var.azure_vnet_subnet_cidr
      ovh_subnet   = var.network.regions[0].subnet

      # Henter automatisk din VPN-maskines interne IP fra det andet modul:
      vpn_internal_ip = module.vpnvm.vm_ip

      # Her fødes de to variabler til dit WireGuard interface:
      testvm_private_key = local.testvm_priv
      vpn_public_key     = local.vpn_pub
    })
  })

  # Vigtigt: testvm må først bygges når netværk og vpnvm er klar
  depends_on = [module.network, module.vpnvm]
}
