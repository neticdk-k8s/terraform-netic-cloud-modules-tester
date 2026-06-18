# Test_K8S_Contain_Azure

Deployer to AKS-clustere på Azure — et **service**-cluster og et **utility**-cluster — hver
bootstrappet med Flux mod både gotk- og kubernetes-config-repoet. Derudover oprettes et VNet med
subnets samt tre storage accounts (mimir/tempo/loki) med adgang via connection strings.

## Ressourcer

| Modul / ressource | Beskrivelse |
|---|---|
| `network` | Azure VNet med subnets (`aks`, `default`) |
| `service_cluster` | AKS — stateless apps |
| `utility_cluster` | AKS — utility workloads |
| `*_flux_bootstrap` | Flux CD bootstrappet mod gotk-repoet pr. cluster |
| `*_kubernetes_config` | Flux bootstrappet mod kubernetes-config-repoet pr. cluster |
| `storage_object` | Tre storage accounts (`for_each` over `storage_config.names`) |
| `azurerm_role_assignment.*_network` | Network Contributor på aks-subnet pr. cluster |

## Konfiguration

Alle parametre har defaults i `variables.tf`. De vigtigste:

### `cloud_settings`

```hcl
cloud_settings = {
  region = "denmarkeast"
  azure = {
    subscription_id = "<subscription-id>"
    resource_group  = "rg-tbr-test"     # skal eksistere i forvejen
    dns_prefix      = "neticcontain"     # unikt pr. template
  }
  ip_restrictions = ["<din IP>/32"]
}
```

### `storage_config`

```hcl
storage_config = {
  names = ["k8smimirtbr", "k8stempotbr", "k8slokitbr"]  # 3-24 lowercase alfanum, INGEN underscores
}
```

> Azure storage account-navne skal være **globalt unikke** og 3-24 lowercase alfanumeriske tegn.
> Et tilfældigt suffiks hægtes på i `main.tf` (`random_string.storage_suffix`) for at sikre unikhed.

### `service_cluster` / `utility_cluster`

Hvert cluster har `cluster_config`, `node_config` og `kubernetes_config`. Se `variables.tf` for
fulde defaults (node_size, availability zones, autoskalering, bootstrap-paths osv.).

## Outputs

| Output | Beskrivelse |
|---|---|
| `vnet_id` / `subnet_ids` | VNet- og subnet-ID'er |
| `service_cluster_id` / `utility_cluster_id` | Cluster-ID'er |
| `service_cluster_kubeconfig` / `utility_cluster_kubeconfig` | Raw kubeconfig pr. cluster (sensitiv) |
| `storage_object_ids` | Map: account-navn → ID |
| `storage_object_names` | Map: account-navn → oprettet navn |
| `storage_object_connection_strings` | Map: account-navn → connection string (sensitiv) |

```bash
# Kubeconfig pr. cluster
tofu output -raw service_cluster_kubeconfig > ~/.kube/aks-s.yaml
tofu output -raw utility_cluster_kubeconfig > ~/.kube/aks-u.yaml

# Connection string til en storage account (giver fuld adgang)
tofu output -json storage_object_connection_strings | jq -r '.["k8smimirtbr"]'
```

### Via GitHub Actions

Efter `deploy` samler workflowet outputs som artifact `outputs-Test_K8S_Contain_Azure`:
`kubeconfig-*.yaml` + `storage-connection-strings.json`.

> ⚠️ **Kun test.** Artifacts indeholder hemmeligheder i klartekst (retention 1 dag). Brug
> ikke denne fremgangsmåde i produktion — se advarslen i `deployinfrastructure.yml`.

## Credentials (env vars / GitHub Secrets)

```bash
# Azure service principal
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_TENANT_ID="..."
export ARM_SUBSCRIPTION_ID="..."

# S3 state-backend (OVH object storage)
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

# GitOps / Flux
export TF_VAR_netic_git_username="..."
export TF_VAR_netic_git_token="..."
export TF_VAR_gitops_ssh_key="$(cat ./flux-deploy-key)"
```

## Lokalt

```bash
cp ../providers.tf providers.tf
cp ../backend.tf backend.tf
cp ../common.auto.tfvars common.auto.tfvars

# Både bucket og key skal angives — backend.tf har ingen defaults
tofu init \
  -backend-config="bucket=terraform-state-tbr" \
  -backend-config="key=Test_K8S_Contain_Azure_local/tofu.tfstate"
tofu plan
```
