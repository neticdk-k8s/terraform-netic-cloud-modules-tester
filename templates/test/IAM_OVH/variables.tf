variable "ovh_api_region" {
  type        = string
  description = "OVH API endpoint region (e.g. 'ovh-eu', 'ovh-ca')"
  default     = "ovh-eu"
}

variable "cloud_settings" {
  type = object({
    region = string
    ovh = optional(object({
      project_id = string
    }), null)
  })
  description = "OVH project and region"
  default = {
    region = "GRA9"
    ovh = {
      project_id = "bb219a2fd02c487798bbb0b349f622a5"
    }
  }
}

variable "openstack_user_config" {
  type = object({
    description = optional(string, "test-iam-openstack-user")
    # Rettigheder (roller) tildelt OpenStack-brugeren i Public Cloud-projektet.
    role_names = optional(list(string), ["administrator"])
  })
  description = "OpenStack-bruger oprettet i Public Cloud-projektet via ovh_cloud_project_user"
  default     = {}
}

variable "ovh_users" {
  type = map(object({
    login       = string
    email       = string
    description = optional(string, "")
    # Main group brugeren placeres i. Default DEFAULT hvis feltet udelades.
    group = optional(string, "DEFAULT")
  }))
  description = "OVH account-level identity-brugere. Map-noeglen er en intern reference."
  default = {
    awl = {
      login       = "awl"
      email       = "awl@netic.dk"
      description = "Anders Wendtland Lanng"
      group       = "ADMIN"
    }
    rkj = {
      login       = "rkj"
      email       = "rkj@netic.dk"
      description = "Rasmus Kirkebaek Jensen"
      group       = "ADMIN"
    }
    mem = {
      login       = "mem"
      email       = "mem@netic.dk"
      description = "Marius Eis Mikkelsen"
      group       = "ADMIN"
    }
    jko = {
      login       = "jko"
      email       = "jko@netic.dk"
      description = "Marius Eis Mikkelsen"
      group       = "ADMIN"
    }
  }
}
