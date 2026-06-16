# Test_Image_OPNsense_OVH

Uploader OPNsense-imaget til OVH-projektets Glance. Templaten har sin **egen state** og opretter intet andet — så imaget overlever, når du river VM/netværk ned i [Test_VM_OPNsense_OVH](../Test_VM_OPNsense_OVH).

## Sådan hænger det sammen

1. Kør denne template **én gang** → imaget ligger i projektet.
2. I `Test_VM_OPNsense_OVH` sætter du `image_config = { upload = false }` (og evt. `vm_config.image_name = "OPNsense"`), så VM'en bare slår imaget op på navn.
3. `tofu destroy` i VM-mappen rører ikke imaget — det lever i denne templates state.

## Ressourcer

| Ressource | Beskrivelse |
|---|---|
| `openstack_images_image_v2` | OPNsense custom image i Glance |

## Konfiguration

### `cloud_settings`

```hcl
cloud_settings = {
  region = "GRA9"
  ovh = {
    project_id = "<dit OVH project ID>"
  }
}
```

### `image_config`

```hcl
image_config = {
  name             = "OPNsense"
  source_url       = "https://mirror.dns-root.de/opnsense/releases/25.1/OPNsense-25.1-nano-amd64.img.bz2"
  # local_file_path = "./OPNsense-25.1-nano-amd64.img"  # alternativ til source_url
  disk_format      = "raw"   # OPNsense nano er raw, ikke qcow2
  decompress       = true     # udpakker .bz2/.gz automatisk
  min_disk_gb      = 10
}
```

## Outputs

| Output | Beskrivelse |
|---|---|
| `image_id` | Glance image ID |
| `image_name` | Navn — brug som `vm_config.image_name` i VM-templaten |

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

tofu init -backend-config="key=Test_Image_OPNsense_OVH_local/tofu.tfstate"
tofu apply
```

> ⚠️ Kør **ikke** `tofu destroy` her, hvis VM-templaten stadig bruger imaget — så forsvinder det.
