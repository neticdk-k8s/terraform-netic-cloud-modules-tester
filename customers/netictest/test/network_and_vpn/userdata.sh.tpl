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
# 1. DYNAMISK DETEKTERING AF NETKORT & ROUTING FIX
# ==============================================================================
# 1. Spørg Linux hvilket netkort, der sidder på dit private vRack subnet
PRIV_NIC=$(ip route | grep "$ovh_subnet" | awk '{print $3}')

# 2. Find det offentlige internet-kort (alt undtagen loopback, wireguard og det private kort)
PUB_NIC=$(ls /sys/class/net/ | grep -v -E "lo|wg" | grep -v "$PRIV_NIC" | head -n 1)

# Gør maskinen i stand til at agere router mellem WG og IPsec
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# 🚀 ROUTING FIX: Slet standard-gatewayen på det private vRack-kort ($PRIV_NIC), 
# så internet- og VPN-trafik tvinges ud via det offentlige kort ($PUB_NIC)
ip route del default dev $PRIV_NIC 2>/dev/null

# ==============================================================================
# 2. INSTALLATION AF PAKKER (Uden irriterende popups)
# ==============================================================================
export DEBIAN_FRONTEND=noninteractive

echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections

apt-get update
apt-get install -y wireguard strongswan iptables-persistent

# Hent den offentlige IP direkte fra det dynamisk fundne internet-kort
PUBLIC_IP=$(ip -4 addr show $PUB_NIC | grep -oP '(?<=inet\s)[0-9.]+')

# Fallback til curl hvis netkortet gemmer IP'en bag en intern IP (afhænger af OVH-region)
if [ -z "$PUBLIC_IP" ] || [[ "$PUBLIC_IP" == 10.* ]] || [[ "$PUBLIC_IP" == 192.168.* ]]; then
  PUBLIC_IP=$(curl -s https://4.icanhazip.com)
fi

# ==============================================================================
# 3. WIREGUARD KONFIGURATION (Tunnel der omgår OVH Port Security)
# ==============================================================================
mkdir -p /etc/wireguard
cd /etc/wireguard
umask 077

wg genkey | tee server_private.key | wg pubkey > server_public.key
SERVER_PRIV_KEY=$(cat server_private.key)

cat <<EOF > /etc/wireguard/wg0.conf
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIV_KEY
EOF

systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# ==============================================================================
# 4. STRONGSWAN KONFIGURATION (Site-to-Site tunnel til Azure)
# ==============================================================================
cat <<EOF > /etc/ipsec.conf
config setup
    charondebug="ike 1, knl 1, cfg 1"
    uniqueids=yes

conn azure-s2s
    authby=secret
    auto=start
    type=tunnel
    keyexchange=ikev2
    
    # Local side (OVH) 
    # 🚀 FIX: Vi låser left til den ægte public IP, så strongSwan ikke vælger privat-IP'en
    left=$PUBLIC_IP
    leftid=$PUBLIC_IP
    leftsubnet=10.8.0.0/24 
    
    # Azure side
    right=$azure_ip
    rightid=$azure_ip
    rightsubnet=$azure_subnet
    
    # Kryptering der matcher Azure standard-indstillinger 100%
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256!
    
    # --- LIFETIMES & TIMERS ---
    keylife=27000s
    ikelifetime=27000s
    
    dpddelay=15s
    dpdtimeout=45s
    dpdaction=restart
EOF

# Konfigurer din Pre-Shared Key / IPsec Nøgle
cat <<EOF > /etc/ipsec.secrets
%any $azure_ip : PSK "$azure_psk"
EOF

systemctl enable strongswan-starter
systemctl restart strongswan-starter

# ==============================================================================
# 5. FIREWALL & ROUTING (IPTABLES)
# ==============================================================================
# Nulstil gamle regler for en sikkerheds skyld
iptables -F FORWARD

# Tillad alt trafik ind og ud af WireGuard-interfacet (wg0)
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

# Tillad IPsec-motoren (strongSwan) i Linux-kernen at route pakkerne
iptables -A FORWARD -m policy --dir in --pol ipsec -j ACCEPT
iptables -A FORWARD -m policy --dir out --pol ipsec -j ACCEPT

# 🚀 FIX: Giver dine WireGuard-klienter internetadgang ud igennem det dynamiske internet-kort ($PUB_NIC)
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $PUB_NIC -j MASQUERADE

# Gem reglerne, så de overlever en genstart af din VM
netfilter-persistent save