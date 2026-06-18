output "openstack_user_name" {
  description = "Brugernavn for OpenStack-brugeren"
  value       = ovh_cloud_project_user.user.username
}

output "openstack_user_password" {
  description = "Autogenereret adgangskode for OpenStack-brugeren"
  value       = ovh_cloud_project_user.user.password
  sensitive   = true
}

output "openstack_user_roles" {
  description = "Roller (rettigheder) tildelt OpenStack-brugeren"
  value       = ovh_cloud_project_user.user.role_names
}

output "ovh_user_logins" {
  description = "Login pr. OVH identity-bruger"
  value       = { for k, u in ovh_me_identity_user.user : k => u.login }
}

output "ovh_user_passwords" {
  description = "Autogenereret adgangskode pr. OVH identity-bruger"
  value       = { for k, p in random_password.ovh_user : k => p.result }
  sensitive   = true
}

output "ovh_user_urns" {
  description = "URN pr. OVH identity-bruger"
  value       = { for k, u in ovh_me_identity_user.user : k => u.urn }
}
