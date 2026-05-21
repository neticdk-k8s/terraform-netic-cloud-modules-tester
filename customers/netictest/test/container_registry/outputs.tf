output "registry_url" {
  value       = module.container_registry.registry_url
  description = "The public URL endpoint of the provisioned Container Registry"
}

output "user" {
  value       = module.container_registry.user
  description = "The generated user used for authenticating against the registry"
}

output "password" {
  value       = module.container_registry.password
  sensitive   = true
  description = "The generated password used for authenticating against the registry (Marked Sensitive)"
}