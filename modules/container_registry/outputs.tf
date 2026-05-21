output "registry_url" {
  value       = ovh_cloud_project_containerregistry.registry.url
  description = "The public URL endpoint of the provisioned Container Registry"
}

output "username" {
  value       = ovh_cloud_project_containerregistry_user.user.user
  description = "The generated username used for authenticating against the registry"
}

output "password" {
  value       = ovh_cloud_project_containerregistry_user.user.password
  sensitive   = true
  description = "The generated password used for authenticating against the registry (Marked Sensitive)"
}