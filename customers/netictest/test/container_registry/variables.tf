## Common variables
variable "ovh_project_id" {}
variable "ovh_region"   { }
variable "ovh_api_region" { }
variable "ovh_project_name" { } 

variable "environment" {}
variable "name_prefix"{} 

## local variables

variable "container_registry" {
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

variable "registry_users" {
  type = list(object({
    login = string
    email = string
  }))
  description = "List of user accounts to create in the container registry"
  
  default = [
    {
      login = "netic-registry-user"
      email = "infra-automation@netic.dk"
    },
    {
      login = "github-actions-cicd"
      email = "github-automation@netic.dk"
    },
    {
      login = "dev-lead-readwrite"
      email = "dev-lead@netic.dk"
    },
    {
      login = "external-partner-ro"
      email = "consultant@externalpartner.com"
    },
    {
      login = "argocd-cluster-puller"
      email = "k8s-automation@netic.dk"
    }
  ]
}