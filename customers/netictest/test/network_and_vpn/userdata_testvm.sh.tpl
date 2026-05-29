#!/bin/bash

# ==============================================================================
# VARIABLER (Indsat dynamisk af Terraform templatefile)
# ==============================================================================
ovh_subnet="${ovh_subnet}"
azure_subnet="${azure_subnet}"
azure_ip="${azure_ip}"
azure_psk="${azure_psk}"

# For DEBUG / TEST logind:
echo "ubuntu:Kodeord1" | chpasswd

# ==============================================================================
# USER_DATA: TEST VM (WIREGUARD KLIENT MOD AZURE VIA VPN-GW)
# ==============================================================================

export DEBIAN_FRONTEND=noninteractive

# 1. Installer WireGuard
apt-get update
apt-get install -y wireguard

# 2. Opret WireGuard konfiguration
mkdir -p /etc/wireguard
cd /etc/wireguard
umask 077

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = ${testvm_private_key}
Address = 10.8.0.2/24

[Peer]
PublicKey = ${vpn_public_key}
Endpoint = ${vpn_internal_ip}:51820
AllowedIPs = ${azure_subnet}
PersistentKeepalive = 25
EOF

# 3. Start og aktiver tildelingen af WireGuard ruter
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0