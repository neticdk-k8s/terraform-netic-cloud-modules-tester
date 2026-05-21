
module "container_registry" {
  source = "../../../../modules/ovh_container_registry"
  
  project_id         = var.project_id
  container_registry = var.container_registry
}
