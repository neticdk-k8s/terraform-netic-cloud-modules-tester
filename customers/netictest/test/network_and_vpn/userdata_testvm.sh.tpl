#!/bin/bash

# ==============================================================================
# VARIABLER (Indsat dynamisk af Terraform templatefile)
# ==============================================================================
ovh_subnet="${ovh_subnet}"
azure_subnet="${azure_subnet}"

# For DEBUG / TEST logind:
echo "ubuntu:Kodeord1" | chpasswd

# ==============================================================================
# USER_DATA: TEST VM (WIREGUARD KLIENT MOD AZURE VIA VPN-GW)
# ==============================================================================

# 🚀 RETTET: Vi leder efter dit OVH-subnet i routingen for at finde det lukkede vRack-kort
PRIV_NIC=$(ip route | grep "$ovh_subnet" | grep -oP '(?<=dev\s)[a-z0-9]+' | head -n 1)

# Hvis den mod forventning ikke finder det, skyder vi på det første kort (ens3)
if [ -z "$PRIV_NIC" ]; then PRIV_NIC="ens3"; fi

# Slet den uduelige standard-gateway på det private vRack-kort ($PRIV_NIC), så Ubuntu 
# tvinges til at bruge internet-kortet (Ext-Net) til at hente WireGuard-pakkerne
ip route del default dev $PRIV_NIC 2>/dev/null

export DEBIAN_FRONTEND=noninteractive

# 1. Installer WireGuard (Nu er der hul igennem til internettet!)
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

# 3. Start og aktiver tildelingen av WireGuard ruter
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0