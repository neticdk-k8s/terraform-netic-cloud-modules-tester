# IAM_OVH

Opretter brugere i et OVH Public Cloud-miljoe:

1. En **OpenStack-bruger** i Public Cloud-projektet med `administrator`-rolle.
2. Et antal **OVH account-level identity-brugere**, alle i `ADMIN`-gruppen (admins).

## Ressourcer

| Ressource | Beskrivelse |
|---|---|
| `ovh_cloud_project_user` | OpenStack-bruger i projektet (administrator-rolle) |
| `ovh_me_identity_user` | OVH account-level identity-brugere (ADMIN-gruppe) |
| `random_password` | Autogenereret adgangskode pr. OVH-bruger |

## Konfiguration

Alle parametre har defaults i `variables.tf` og kan overrides med en `.tfvars`-fil eller `TF_VAR_*`-env vars.

### `cloud_settings`

```hcl
cloud_settings = {
  region = "GRA9"
  ovh = {
    project_id = "<dit OVH project ID>"
  }
}
```

### `ovh_users`

Map af identity-brugere. Map-noeglen er en intern reference. Alle er admins (`group = "ADMIN"`).

```hcl
ovh_users = {
  awl = { login = "awl", email = "awl@netic.dk", description = "Anders Wendtland Lanng" }
  rkj = { login = "rkj", email = "rkj@netic.dk", description = "Rasmus Kirkebaek Jensen" }
  mem = { login = "mem", email = "mem@netic.dk", description = "Marius Eis Mikkelsen" }
  jko = { login = "jko", email = "jko@netic.dk", description = "Marius Eis Mikkelsen" }
}
```

## Outputs

| Output | Beskrivelse |
|---|---|
| `openstack_user_name` | OpenStack-brugerens brugernavn |
| `openstack_user_password` | OpenStack-brugerens adgangskode (sensitive) |
| `openstack_user_roles` | Tildelte roller |
| `ovh_user_logins` | Login pr. OVH-bruger |
| `ovh_user_passwords` | Adgangskode pr. OVH-bruger (sensitive) |
| `ovh_user_urns` | URN pr. OVH-bruger |

```bash
tofu output -json ovh_user_passwords
tofu output -raw openstack_user_password
```

## Lokalt

```bash
cp ../providers.tf providers.tf
cp ../backend.tf backend.tf
cp ../common.auto.tfvars common.auto.tfvars

export OVH_ENDPOINT="ovh-ca"
export OVH_APPLICATION_KEY="..."
export OVH_APPLICATION_SECRET="..."
export OVH_CONSUMER_KEY="..."
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export OS_USERNAME="..."
export OS_PASSWORD="..."

tofu init -backend-config="key=IAM_OVH_local/tofu.tfstate"
tofu plan
```
