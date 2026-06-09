# Test_K8S_Azure

Deployer en komplet Kubernetes-platform på Azure med VNet, ACR, AKS, Blob Storage og GitOps via Flux.

## Ressourcer

| Modul | Ressourcer |
|---|---|
| `network` | Azure VNet med subnets og NSGs |
| `registry` | Azure Container Registry (ACR) med brugere og IP-restriktioner |
| `kubernetes` | Azure Kubernetes Service (AKS) med nodepool |
| `storage_object` | Azure Blob Storage |
| `flux_bootstrap` | Flux CD bootstrappet mod cluster-repo |
| `azurerm_role_assignment` | Network Contributor på AKS-subnet |

## Konfiguration

### `cloud_settings`

```hcl
cloud_settings = {
  region = "denmarkeast"
  azure = {
    subscription_id = "<subscription-id>"
    resource_group  = "rg-netic-test"   # skal eksistere i forvejen
    dns_prefix      = "netictest"
  }
  ip_restrictions = ["<din IP>/32"]
}
```

> **Bemærk:** Resource group skal oprettes manuelt i Azure inden deploy.

### `registry_config`

```hcl
registry_config = {
  deploy = true
  name   = "netictestreg001"   # globalt unikt, 5-50 alfanumeriske tegn
  sku    = "Basic"             # Basic / Standard / Premium (Premium til IP-restriktioner)
}
```

### `storage_config`

```hcl
storage_config = {
  name = "neticteststg001"   # globalt unikt, 3-24 lowercase alfanumeriske tegn
}
```

## Outputs

```bash
# Hent kubeconfig efter deploy (via GitHub Actions artifact)
export KUBECONFIG=./kubeconfig.yaml
kubectl get nodes
k9s
```

| Output | Beskrivelse |
|---|---|
| `cluster_id` | AKS resource ID |
| `kubeconfig` | Raw kubeconfig (sensitiv) |
| `registry_url` | Login-URL til ACR |
| `storage_object_name` | Navn på storage account |

## Credentials

```bash
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."

export TF_VAR_netic_git_username="..."
export TF_VAR_netic_git_token="..."
export TF_VAR_gitops_ssh_key="$(cat ~/.ssh/flux-deploy-key)"
```

## Lokalt

```bash
cp ../providers.tf providers.tf
cp ../backend.tf backend.tf
cp ../common.auto.tfvars common.auto.tfvars

terraform init
terraform plan
```
