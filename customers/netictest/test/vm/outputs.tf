output "control_plane_ids" {
  description = "List of IDs for all control plane VMs"
  value       = module.control_plane[*].vm_id
}

output "control_plane_names" {
  description = "List of names for all control plane VMs"
  value       = module.control_plane[*].vm_name
}

output "control_plane_ips" {
  description = "List of primary IP addresses for the control plane VMs"
  value       = module.control_plane[*].vm_ip
}