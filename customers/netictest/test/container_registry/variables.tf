## Common variables
variable "ovh_project_id" {}
variable "ovh_region"   { }
variable "ovh_api_region" { }
variable "ovh_project_name" { } 

variable "environment" {}
variable "name_prefix"{} 

## local variables

variable "ContainerRegistry" {
  type = object({
    deploy = bool
    name   = string
    region = string

  })
  default = {
    deploy = true
    name   = "my-docker-private-registry"
    region = "DE"
  }
}