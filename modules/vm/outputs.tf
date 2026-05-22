output "vm_id" {
  description = "The ID of the created virtual machine"
  value       = local.is_windows ? openstack_compute_instance_v2.VMWindows[0].id : openstack_compute_instance_v2.VMLinux[0].id
}

output "vm_name" {
  description = "The name of the created virtual machine"
  value       = local.is_windows ? openstack_compute_instance_v2.VMWindows[0].name : openstack_compute_instance_v2.VMLinux[0].name
}

output "vm_ip" {
  description = "The primary IPv4 address of the virtual machine"
  value       = local.is_windows ? openstack_compute_instance_v2.VMWindows[0].access_ip_v4 : openstack_compute_instance_v2.VMLinux[0].access_ip_v4
}