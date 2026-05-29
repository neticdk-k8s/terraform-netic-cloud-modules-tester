######################################
###           Outputs              ###
######################################

output "vm_name" {
  description = "The name of the created virtual machine"
  value       = local.is_windows ? one(openstack_compute_instance_v2.VMWindows[*].name) : one(openstack_compute_instance_v2.VMLinux[*].name)
}

output "vm_ip" {
  description = "The primary IPv4 address of the virtual machine"
  value       = local.is_windows ? one(openstack_compute_instance_v2.VMWindows[*].access_ip_v4) : one(openstack_compute_instance_v2.VMLinux[*].access_ip_v4)
}

output "primary_port_id" {
  description = "The ID of the first network interface port"
  value       = values(openstack_networking_port_v2.vm_ports)[0].id
}

