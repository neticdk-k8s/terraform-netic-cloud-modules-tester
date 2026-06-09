# Test_Net_Azure

Opretter et Azure Virtual Network med subnets og tilhørende Network Security Groups.

## Ressourcer

| Ressource | Beskrivelse |
|---|---|
| `azurerm_virtual_network` | VNet |
| `azurerm_subnet` | Subnet pr. entry i `network_config.subnets` |
| `azurerm_network_security_group` | NSG pr. subnet |
| `azurerm_subnet_network_security_group_association` | Tilknytning NSG → subnet |

## Konfiguration

### `cloud_settings`

```hcl
cloud_settings = {
  region = "denmarkeast"
  azure = {
    subscription_id = "<subscription-id>"
    resource_group  = "rg-netic-test"   # skal eksistere i forvejen
  }
}
```

> **Bemærk:** Resource group skal oprettes manuelt i Azure inden deploy.

### `network_config`

```hcl
network_config = {
  name          = "vnet-netic-test"
  address_space = ["10.0.12.0/22"]
  subnets = {
    aks     = { cidr = "10.0.12.0/24" }
    default = { cidr = "10.0.13.0/24" }
  }
}
```

## Outputs

| Output | Beskrivelse |
|---|---|
| `network_id` | VNet resource ID |
| `subnet_ids` | Map af subnet-navne til subnet-IDs |

## Lokalt

```bash
cp ../providers.tf providers.tf
cp ../backend.tf backend.tf
cp ../common.auto.tfvars common.auto.tfvars

export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."

terraform init
terraform plan
```
