locals {
  project_id = var.cloud_settings.ovh.project_id
}

# =============================================================================
# OpenStack-bruger — oprettes i Public Cloud-projektet med administrator-rolle.
# =============================================================================
resource "ovh_cloud_project_user" "user" {
  service_name = local.project_id
  description  = var.openstack_user_config.description
  role_names   = var.openstack_user_config.role_names
}

# =============================================================================
# OVH identity-brugere — alle i ADMIN-gruppen (admins).
# Adgangskode autogenereres pr. bruger (se output ovh_user_passwords).
# =============================================================================
resource "random_password" "ovh_user" {
  for_each = var.ovh_users

  length           = 16
  special          = true
  override_special = "!#%*-_=+"
}

resource "ovh_me_identity_user" "user" {
  for_each = var.ovh_users

  login       = each.value.login
  email       = each.value.email
  description = each.value.description
  group    = each.value.group
  password = random_password.ovh_user[each.key].result
}
