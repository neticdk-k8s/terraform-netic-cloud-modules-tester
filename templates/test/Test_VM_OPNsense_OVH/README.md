# Test_VM_OPNsense_OVH

Opretter et privat OVH vRack-netværk og en VM med OPNsense-image. VM'en får et NIC på Ext-Net (public) og et NIC på det private netværk, så den kan fungere som firewall/gateway.

## Ressourcer

| Ressource | Beskrivelse |
|---|---|
| `ovh_cloud_project_network_private` | Privat vRack-netværk |
| `ovh_cloud_project_network_private_subnet` | Subnet pr. region (no_gateway = true, da OPNsense selv er gateway) |
| `openstack_compute_instance_v2` | OPNsense VM med public + privat NIC |
| `ovh_cloud_project_ssh_key` / `openstack_compute_keypair_v2` | SSH-nøgle (autogenereres hvis ingen angives) |

## Forudsætninger

OVH har ikke et stock OPNsense-image — det skal uploades til projektet som custom image (Glance) først, fx:

```bash
openstack image create "OPNsense" \
  --disk-format qcow2 --container-format bare \
  --file OPNsense-25.1-nano-amd64.img
```

`vm_config.image_name` skal matche image-navnet.

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

### `networks`

Liste af private vRack-netværk. Hvert element bliver til et netværk + subnet, og VM'en får et NIC på hvert (i listens rækkefølge).

```hcl
networks = [
  {
    name    = "vnet_test_opnsense_ovh"
    vlan_id = 321            # Unikt VLAN-ID på tværs af vRack (1–4000)
    regions = [
      {
        region     = "GRA9"
        subnet     = "10.0.15.0/24"
        dhcp       = true
        no_gateway = true    # OPNsense er selv gateway
      }
    ]
  },
  # ... flere netværk efter behov
]
```

### `vm_config`

```hcl
vm_config = {
  name             = "opnsense-fw-test"
  size             = "b2-7"
  image_name       = "OPNsense"   # Navn på uploadet custom image
  create_public_ip = true          # Tilføjer Ext-Net som første NIC (WAN)
  ssh_public_key   = null          # null = autogenerér nøgle (se output ssh_private_key)
}
```

## Outputs

| Output | Beskrivelse |
|---|---|
| `vm_name` | VM'ens navn |
| `vm_ip` | Primær privat IPv4 |
| `public_ip` | Public IP (WAN) |
| `ssh_private_key` | Autogenereret privat SSH-nøgle (sensitive) |

```bash
tofu output -raw ssh_private_key > opnsense_key.pem && chmod 600 opnsense_key.pem
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

tofu init -backend-config="key=Test_VM_OPNsense_OVH_local/tofu.tfstate"
tofu plan
```
