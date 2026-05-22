output "control_plane_ips" {
  value       = module.control_plane[*].vm_ip
  description = "List of all private IPv4 addresses assigned to the control plane instances"
}

output "control_plane_ssh_keys" {
  value       = module.control_plane[*].private_ssh_key
  description = "List of all generated private SSH keys. Run 'terraform output -json' to view them."
  sensitive   = true # Must be marked sensitive since the module output is sensitive
}