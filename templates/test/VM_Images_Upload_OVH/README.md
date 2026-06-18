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

export OVH_ENDPOINT="ovh-eu"
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


# Custom config
For at lave custom image der kan få config fra Github laves  

1 - lav opnsense vha terraform
2 - log på consol af opnsense  (login : root/opnsense)
3 - Sæt netkort op og angiv IP
4 - kør pfctl -d i consol (disable firewall), således at der kan logges på terminal
5 - lav rettelser i portal: Firewall regel på WAN, så port 22 + 443 er åben udefra (evt specifik ip)
6 - system / settings : Enable SSH + enable password login
7 - save og træk konfiguration :   scp root@147.135.234.224:/conf/config.xml ./opnsense_config.xml
8 - lav script til at bootstrap  (ret github ref) : 
9 - scp 99-github-config root@147.135.234.224:/usr/local/etc/rc.syshook.d/start/ 
10 - kør chmod +x /usr/local/etc/rc.syshook.d/start/99-github-config

## Test funktion

Hvis  .github-config-applied ligger der, vil det fejle
ssh root@ip
rm -f /conf/.github-config-applied
reboot
