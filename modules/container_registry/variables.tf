# modules/ovh_container_registry/variables.tf

variable "project_id" {
  type        = string
  description = "OVH cloud projektets service ID"
}

variable "container_registry" {
  type = object({
    deploy = bool
    name   = string
    region = string
  })
  description = "Configuration of OVH Container Registry"
}

variable "registry_user_email" {
  type        = string
  default     = "infra-automation@netic.dk"
  description = "Primary email address associated with the registry user account"
}

variable "registry_user_login" {
  type        = string
  default     = "netic-registry-user"
  description = "The login username for the primary registry user account"
}