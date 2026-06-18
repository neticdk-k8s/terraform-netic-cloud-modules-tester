# Test_K8S_Contain_OVH

Deployer to Kubernetes-clustere på OVHcloud — et **service**-cluster og et **utility**-cluster —
hver bootstrappet med Flux mod både gotk- og kubernetes-config-repoet. Derudover oprettes tre
object storage buckets (mimir/tempo/loki) samt en dedikeret S3-bruger med adgang til dem.

## Ressourcer

| Modul / ressource | Beskrivelse |
|---|---|
| `service_cluster` | OVH Managed Kubernetes (MKS) — stateless apps |
| `utility_cluster` | OVH Managed Kubernetes (MKS) — utility workloads |
| `*_flux_bootstrap` | Flux CD bootstrappet mod gotk-repoet pr. cluster |
| `*_kubernetes_config` | Flux bootstrappet mod kubernetes-config-repoet pr. cluster |
| `storage_object` | Tre S3-kompatible buckets (`for_each` over `storage_config.names`) |
| `ovh_cloud_project_user.storage` | Dedikeret bruger med `objectstore_operator`-rolle |
| `ovh_cloud_project_user_s3_credential.storage` | S3-nøglepar til storage-brugeren |
| `ovh_cloud_project_user_s3_policy.storage` | Policy der begrænser brugeren til de tre buckets |

> Netværksmodulet er udkommenteret i `main.tf` — clusterne kører uden privat vRack-netværk.
> Gen-aktivér `module "network"` + dets outputs, hvis de skal på vRack.

## Konfiguration

Alle parametre har defaults i `variables.tf`. De vigtigste:

### `cloud_settings`

```hcl
cloud_settings = {
  region = "GRA9"                  # compute-region (MKS-noder)
  ovh = {
    project_id = "<dit OVH project ID>"
  }
  ip_restrictions = ["<din IP>/32"]
}
```

### `storage_config`

```hcl
storage_config = {
  names = ["k8s-mimir-tbr", "k8s-tempo-tbr", "k8s-loki-tbr"]  # bindestreger — IKKE underscores
  ovh = {
    region = "GRA"                 # S3-region (kort kode, ikke "GRA9")
  }
}
```

> OVH bucket-navne skal matche `^[a-z0-9][a-z0-9.\-]{1,61}[a-z0-9]$` — ingen underscores.

### `service_cluster` / `utility_cluster`

Hvert cluster har `cluster_config`, `node_config` og `kubernetes_config`. Se `variables.tf`
for fulde defaults (node_size, autoskalering, bootstrap-paths osv.).

## Outputs

| Output | Beskrivelse |
|---|---|
| `service_cluster_id` / `utility_cluster_id` | Cluster-ID'er |
| `service_cluster_kubeconfig` / `utility_cluster_kubeconfig` | Raw kubeconfig pr. cluster (sensitiv) |
| `storage_object_ids` | Map: bucket-navn → storage-ID |
| `storage_object_names` | Map: bucket-navn → oprettet navn |
| `storage_s3_access_key` | S3 access key til storage-brugeren |
| `storage_s3_secret_key` | S3 secret key (sensitiv) |

```bash
# Kubeconfig pr. cluster
tofu output -raw service_cluster_kubeconfig > ~/.kube/ovhs.yaml
tofu output -raw utility_cluster_kubeconfig > ~/.kube/ovhu.yaml

# Tilgå de tre buckets med storage-brugerens nøgler
export AWS_ACCESS_KEY_ID="$(tofu output -raw storage_s3_access_key)"
export AWS_SECRET_ACCESS_KEY="$(tofu output -raw storage_s3_secret_key)"
aws s3 ls s3://k8s-mimir-tbr/ --endpoint-url https://s3.gra.io.cloud.ovh.net --region gra
```

### Via GitHub Actions

Efter `deploy` samler workflowet outputs som artifact `outputs-Test_K8S_Contain_OVH`:
`kubeconfig-*.yaml` + `s3-creds.env` (med `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`).

> ⚠️ **Kun test.** Artifacts indeholder hemmeligheder i klartekst (retention 1 dag). Brug
> ikke denne fremgangsmåde i produktion — se advarslen i `deployinfrastructure.yml`.

## Credentials (env vars / GitHub Secrets)

```bash
export OVH_ENDPOINT="ovh-eu"
export TF_VAR_ovh_api_region="ovh-eu"
export OVH_APPLICATION_KEY="..."     # EU-token: https://eu.api.ovh.com/createToken
export OVH_APPLICATION_SECRET="..."
export OVH_CONSUMER_KEY="..."
export OS_USERNAME="..."
export OS_PASSWORD="..."
export AWS_ACCESS_KEY_ID="..."       # OVH S3-bruger til state-backend
export AWS_SECRET_ACCESS_KEY="..."
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
  -backend-config="key=Test_K8S_Contain_OVH_local/tofu.tfstate"
tofu plan
```
