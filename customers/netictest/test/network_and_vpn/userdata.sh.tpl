#!/bin/bash

# ==============================================================================
# VARIABLER (Indsat dynamisk af Terraform templatefile)
# ==============================================================================
ovh_subnet="${ovh_subnet}"
azure_subnet="${azure_subnet}"
azure_ip="${azure_ip}"
azure_psk="${azure_psk}"

# For DEBUG / TEST running: 
echo "ubuntu:Kodeord1" | chpasswd

# 1. IP forwarding (gør maskinen i stand til at agere router)
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# ==============================================================================
# 2. INSTALLATION AF PAKKER (Popup deaktiveret)
# ==============================================================================
export DEBIAN_FRONTEND=noninteractive

echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections

apt-get update
apt-get install -y wireguard strongswan iptables-persistent

# Find denne OVH-maskines eksterne IP-adresse automatisk
PUBLIC_IP=$(curl -s https://4.icanhazip.com)

# ==============================================================================
# 3. WIREGUARD KONFIGURATION (VPN til klienter)
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
# 4. STRONGSWAN KONFIGURATION (Site-to-Site til Azure)
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
    left=%any
    leftid=$PUBLIC_IP
    leftsubnet=$ovh_subnet,10.8.0.0/24 
    
    # Azure side
    right=$azure_ip
    rightid=$azure_ip
    rightsubnet=$azure_subnet
    
    # Kryptering der matcher Azure standard-indstillinger
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256!
    
    dpdaction=restart
    dpddelay=30s
    dpdtimeout=120s
EOF

cat <<EOF > /etc/ipsec.secrets
$PUBLIC_IP $azure_ip : PSK "$azure_psk"
EOF

systemctl enable strongswan-starter
systemctl restart strongswan-starter

# ==============================================================================
# 5. FIREWALL & ROUTING (IPTABLES)
# ==============================================================================
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

iptables -A FORWARD -s $azure_subnet -j ACCEPT
iptables -A FORWARD -d $azure_subnet -j ACCEPT

# Giver dine WireGuard-klienter internetadgang ud igennem OVH maskinen (ret eth0 hvis nødvendigt)
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

netfilter-persistent save