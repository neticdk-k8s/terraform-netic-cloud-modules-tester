# TODO / Roadmap

Struktureret oversigt over hvad der mangler i `terraform-netic-cloud-modules-tester`.
Status: ⬜ ikke startet · 🟡 i gang · ✅ færdig

---

## 1. OPNsense — image, firewall og VPN

Mål: gå fra de manuelle steps i
[`VM_Images_Upload_OVH/README.md`](templates/test/VM_Images_Upload_OVH/README.md)
(sektionen "Custom config", trin 1–10) til en automatiseret, gentagelig opsætning.

### 1a. Automatisk image-upload ⬜
- [ ] Workflow/automatik der uploader OPNsense-imaget til projektets Glance
      (i dag køres `Test_Image_OPNsense_OVH` manuelt via `tofu apply`).
- [ ] Gør det idempotent — upload kun hvis imaget ikke allerede findes.
- [ ] Parametrisér OPNsense-version/`source_url` så opgradering er ét sted.

### 1b. Automatiser config-bootstrap (erstat de manuelle trin 2–10) ⬜
De nuværende manuelle skridt der skal automatiseres:
- [ ] Netkort + IP-opsætning (trin 3)
- [ ] FW-regler: åbn 22 + 443 på WAN, evt. kildebegrænset (trin 5)
- [ ] Enable SSH + password-login (trin 6)
- [ ] Træk/seed `config.xml` (trin 7) — versionér en kendt baseline-config
- [ ] `99-github-config` rc.syshook-script: deploy + `chmod +x` (trin 8–10)
- [ ] Genbrug "test-funktion": fjern `/conf/.github-config-applied` + reboot for re-apply

> Sandsynlig retning: cloud-init / `user_data` på VM'en, eller et baked custom image,
> så ingen manuel konsol-login er nødvendig.

### 1c. Firewall- og VPN-konfiguration ⬜
- [ ] Deklarativ FW-regelsæt-konfiguration (ikke manuelt i portalen)
- [ ] VPN-opsætning (type afklares: IPsec / WireGuard / OpenVPN)
- [ ] Læg konfigurationen i `variables.tf` så den er styrbar pr. deploy

### 1d. Konfigurerbart GitHub-repo ⬜
- [ ] Det repo `99-github-config` henter config fra skal være en **variabel**
      (i dag hardcodet ref i bootstrap-scriptet, trin 8).
- [ ] Eksponér som `TF_VAR_*` / template-variabel + dokumentér i README.

---

## 2. Contain-clustere — gør færdige 🟡

Templates: [`Test_K8S_Contain_OVH`](templates/test/Test_K8S_Contain_OVH),
[`Test_K8S_Contain_Azure`](templates/test/Test_K8S_Contain_Azure)

- [x] Service- + utility-cluster oprettes
- [x] Tre object storage buckets/accounts (mimir/tempo/loki)
- [x] Storage-adgang: OVH S3-bruger+nøgler / Azure connection strings
- [x] Outputs samles som artifact via workflow (test only)
- [ ] **Verificér fuld end-to-end deploy** af begge clustere (apply grøn hele vejen)
- [ ] Privat netværk (vRack/VNet): OVH-netværksmodulet er **udkommenteret** i
      `main.tf` — afklar om clusterne skal på privat net og gen-aktivér i så fald
- [ ] Bekræft Flux-bootstrap mod både gotk- og kubernetes-config-repo virker på begge clustere
- [ ] Afklar om utility-clusteret skal have egne workloads/konfiguration

---

## 3. GitBucket-implementering 🟡

- **Ejer:** Rasmus Wilgaard (undersøger implementering)
- [ ] Afklar scope: hosting af Git-repos (erstatning/supplement til git.netic.dk?)
- [ ] Afklar integration med Flux/GitOps-bootstrap (`flux_bootstrap`, `kubernetes_config`)
- [ ] Beslut om det påvirker det konfigurerbare GitHub-repo i punkt 1d

---

## Tværgående / kendte mangler

- [ ] Lokalt `tofu init` i de øvrige template-READMEs mangler stadig
      `-backend-config="bucket=..."` (rettet i Contain + hoved-README; resten udestår).
- [ ] Produktions-hærdning af credential-håndtering: artifacts med hemmeligheder i
      klartekst (retention 1 dag) er **kun til test** — se advarsel i
      [`deployinfrastructure.yml`](.github/workflows/deployinfrastructure.yml).
