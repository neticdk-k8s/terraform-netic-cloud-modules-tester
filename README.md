# terraform-netic-cloud-modules-tester

OpenTofu-konfigurationer til test-deployment af infrastruktur på OVHcloud og Azure. Moduler hentes fra
[terraform-netic-cloud-modules](https://github.com/neticdk-k8s/terraform-netic-cloud-modules).

## Struktur

```
templates/
└── test/
    ├── providers.tf            # Delt providerkonfiguration (kopieres ind i templates ved kørsel)
    ├── backend.tf              # Delt S3 state-backend (kopieres ind)
    ├── common.auto.tfvars      # Delte variable (kopieres ind)
    ├── Test_Net_OVH/           # OVH privat netværk (vRack)
    ├── Test_Net_Azure/         # Azure VNet med subnets og NSGs
    ├── Test_K8S_Simpel_OVH/    # Ét OVH-cluster med netværk, registry, storage og GitOps
    ├── Test_K8S_Simpel_Azure/  # Ét AKS-cluster med VNet, ACR, storage og GitOps
    ├── Test_K8S_Contain_OVH/   # Service- + utility-cluster på OVH med GitOps-bootstrap
    └── Test_K8S_Contain_Azure/ # Service- + utility-cluster på AKS med GitOps-bootstrap
```

## Deployment via GitHub Actions

Workflowen startes manuelt under **Actions → OpenTofu Plan & Deploy**.

Vælg template og handling:

| Handling | Beskrivelse |
|---|---|
| `plan` | Forhåndsvisning af ændringer — ingen ressourcer oprettes |
| `deploy` | Opretter eller opdaterer ressourcer |
| `destroy` | Nedlægger alle ressourcer i templaten |

## Lokalt

Kopiér de delte filer ind i templatens mappe inden `tofu init`:

```bash
TEMPLATE=Test_Net_OVH   # eller en af de andre template-mapper
cp templates/test/providers.tf     templates/test/$TEMPLATE/providers.tf
cp templates/test/backend.tf       templates/test/$TEMPLATE/backend.tf
cp templates/test/common.auto.tfvars templates/test/$TEMPLATE/common.auto.tfvars
```

Sæt environment-variabler:

```bash
export OVH_ENDPOINT="ovh-ca"
export OVH_APPLICATION_KEY="..."
export OVH_APPLICATION_SECRET="..."
export OVH_CONSUMER_KEY="..."
export AWS_ACCESS_KEY_ID="..."       # OVH S3-bruger til state-filen
export AWS_SECRET_ACCESS_KEY="..."
export OS_USERNAME="..."             # OVH OpenStack-bruger
export OS_PASSWORD="..."
```

```bash
# State-nøglen SKAL angives ved init — backend.tf har bevidst ingen default,
# så templates ikke kan komme til at dele state-fil
tofu -chdir=templates/test/$TEMPLATE init -backend-config="key=${TEMPLATE}_local/tofu.tfstate"
tofu -chdir=templates/test/$TEMPLATE plan
```

## GitHub Secrets og Variables

| Navn | Type | Beskrivelse |
|---|---|---|
| `OVH_ENDPOINT` | Variable | API-region, fx `ovh-ca` |
| `OVH_APPLICATION_KEY` | Secret | OVH API application key |
| `OVH_APPLICATION_SECRET` | Secret | OVH API application secret |
| `OVH_CONSUMER_KEY` | Secret | OVH API consumer key |
| `AWS_ACCESS_KEY_ID` | Secret | OVH S3 access key (state-backend) |
| `AWS_SECRET_ACCESS_KEY` | Secret | OVH S3 secret key (state-backend) |
| `OS_USERNAME` | Secret | OpenStack-brugernavn |
| `OS_PASSWORD` | Secret | OpenStack-password |
| `TF_VAR_NETIC_GIT_USERNAME` | Secret | Git-brugernavn til Flux bootstrap *(K8S)* |
| `TF_VAR_NETIC_GIT_TOKEN` | Secret | Git-token til Flux bootstrap *(K8S)* |
| `TF_VAR_GITOPS_SSH_KEY` | Secret | SSH-nøgle til kubernetes-config repo *(K8S)* |

## State

State gemmes i OVH Object Storage (S3-kompatibel), bucket `terraformstate09999` i Gravelines (GRA).
Hver template/cloud/branch-kombination har sin egen state-fil — nøglen sættes ved `tofu init`
(workflowet gør det automatisk; lokalt skal `-backend-config` angives):

```
<template>_<cloud>_<branch>/tofu.tfstate
```

> **Bemærk:** State skrevet af Terraform bør ikke genbruges af OpenTofu (og omvendt).
> Test-miljøer nedlægges med det værktøj der oprettede dem, og genopbygges med `tofu`.
