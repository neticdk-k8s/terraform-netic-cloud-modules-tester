# Test_K8S_Simpel_OVH

Deployer en komplet Kubernetes-platform på OVHcloud med netværk, container registry,
object storage og GitOps via Flux.

## Ressourcer

| Modul | Ressourcer |
|---|---|
| `network` | Privat vRack-netværk med subnet |
| `registry` | OVH Managed Container Registry med brugere og IP-restriktioner |
| `kubernetes` | OVH Managed Kubernetes (MKS) med nodepool og autoskalering |
| `storage_object` | OVH S3-kompatibel object storage |
| `flux_bootstrap` | Flux CD installeret og bootstrappet mod cluster-repo |

## Konfiguration

Alle parametre har defaults i `variables.tf`. De vigtigste at tilpasse:

### `cloud_settings`

```hcl
cloud_settings = {
  cloud_provider = "ovh"
  region         = "GRA9"
  ovh = {
    project_id = "<dit OVH project ID>"
  }
  ip_restrictions = ["<din IP>/32"]   # Adgang til API-server og registry
}
```

### `cluster_config`

```hcl
cluster_config = {
  cluster_name = "mit-cluster"
  k8s_version  = "1.34"
}
```

### `node_config`

```hcl
node_config = {
  node_size         = "medium"   # small / medium / large
  node_count        = 1
  autoscale_enabled = false
  min_count         = 1
  max_count         = 3
}
```

### `gitops_config`

```hcl
gitops_config = {
  cluster_repo   = "git.netic.dk/scm/pd/gotk-bootstrap-k8s.git"
  bootstrap_path = "gotk"
}
```

## Outputs

```bash
# Hent kubeconfig efter deploy
tofu output -raw kubeconfig > ~/.kube/config

# Åbn cluster i k9s
k9s --kubeconfig ~/.kube/config
```

| Output | Beskrivelse |
|---|---|
| `cluster_id` | ID på Kubernetes-clusteret |
| `kubeconfig` | Raw kubeconfig (sensitiv) |
| `registry_url` | Login-URL til container registry |
| `registry_user_passwords` | Genererede passwords til registry-brugere (sensitiv) |
| `storage_object_name` | Navn på object storage bucket |

## Credentials (sættes som env vars eller GitHub Secrets)

```bash
# OVH + OpenStack
export OVH_ENDPOINT="ovh-ca"
export OVH_APPLICATION_KEY="..."
export OVH_APPLICATION_SECRET="..."
export OVH_CONSUMER_KEY="..."
export OS_USERNAME="..."
export OS_PASSWORD="..."

# S3 state-backend
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."

# GitOps / Flux
export TF_VAR_netic_git_username="..."
export TF_VAR_netic_git_token="..."
export TF_VAR_gitops_ssh_key="$(cat ~/.ssh/flux-deploy-key)"
```

## SSH-nøgle til kubernetes-config repo

```bash
# Generer dedikeret deploy key
ssh-keygen -t ed25519 -C "flux@netic-k8s-test" -f ./flux-deploy-key -N ""

# Tilføj public key som deploy key i kubernetes-config repoet (read-only)
cat flux-deploy-key.pub

# Sæt private key som env var
export TF_VAR_gitops_ssh_key="$(cat ./flux-deploy-key)"
```

## Lokalt

```bash
cp ../providers.tf providers.tf
cp ../backend.tf backend.tf
cp ../common.auto.tfvars common.auto.tfvars

tofu init -backend-config="key=Test_K8S_Simpel_OVH_local/tofu.tfstate"
tofu plan
```
