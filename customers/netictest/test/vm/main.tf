# Example of referencing a network resource (uncomment and adjust if needed)
# data "ovh_cloud_project_network_private" "net" {
#   service_name = var.ovh_project_id
#   name         = var.private_network_name
# }

module "control_plane" {
  source = "../../../../modules/vm"
  count  = var.ControlPlaneVM_VMCount

  ovh_project_id = var.ovh_project_id

  // Update variable with count, so we dont create same machine several times
  vm = merge(var.ControlPlaneVM, {
    name = "${var.ControlPlaneVM.name}-${count.index}"
  })
}

module "control_plane_Windows" {
  source         = "../../../../modules/vm"
  ovh_project_id = var.ovh_project_id
  vm             = var.WindowsVM
}

