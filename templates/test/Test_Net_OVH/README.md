# Test_Net_OVH

Opretter et privat OVH vRack-netværk med subnet og DHCP.

## Ressourcer

| Ressource | Beskrivelse |
|---|---|
| `ovh_cloud_project_network_private` | Privat vRack-netværk |
| `ovh_cloud_project_network_private_subnet` | Subnet pr. region med DHCP og IP-pool |

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

### `network_config`

```hcl
network_config = {
  name    = "mitt-netvaerk"
  vlan_id = 200           # Unikt VLAN-ID på tværs af vRack (1–4000)
  regions = [
    {
      region              = "GRA9"
      subnet              = "10.0.10.0/24"
      dhcp                = true
      no_gateway          = false
      ip_allocation_start = 10
      ip_allocation_stop  = 200
    }
  ]
}
```

## Outputs

Ingen outputs — netværkets ID kan slås op i OVH Control Panel eller via OpenStack CLI.

## Lokalt

```bash
cp ../providers.tf providers.tf
cp ../backend.tf backend.tf
cp ../common.auto.tfvars common.auto.tfvars

export OVH_ENDPOINT="ovh-eu"
export OVH_APPLICATION_KEY="..."
export OVH_APPLICATION_SECRET="..."
export OVH_CONSUMER_KEY="..."
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export OS_USERNAME="..."
export OS_PASSWORD="..."

tofu init -backend-config="key=Test_Net_OVH_local/tofu.tfstate"
tofu plan
```
