resource "ovh_cloud_project_containerregistry" "registry" {
  service_name = var.ovh_project_id
  region       = var.container_registry.region
  name         = var.container_registry.name
}

resource "ovh_cloud_project_containerregistry_user" "user" {
  service_name = ovh_cloud_project_containerregistry.registry.service_name
  registry_id  = ovh_cloud_project_containerregistry.registry.id
  email        = var.registry_user_email
  login        = var.registry_user_login
}