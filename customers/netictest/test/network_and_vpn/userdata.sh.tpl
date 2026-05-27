#!/bin/bash

# 0 For DEBUG / TEST only : 
echo "ubuntu:Kodeord1" | chpasswd

# 1. IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# 2. Installer pakker
apt-get update
apt-get install -y wireguard strongswan iptables-persistent

# Hent maskinens egen public IP dynamisk under boot
PUBLIC_IP=$(curl -s https://4.icanhazip.com)

# ==============================================================================
# 3. WIREGUARD CONFIGURATION
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
# 4. STRONGSWAN CONFIGURATION (Azure)
# ==============================================================================
cat <<EOF > /etc/ipsec.conf
config setup
    charondebug="ike 1, knl 1, cfg 1"

conn azure-s2s
    authby=secret
    auto=start
    type=tunnel
    keyexchange=ikev2
    
    left=%any
    leftid=$PUBLIC_IP
    leftsubnet=${ovh_subnet},10.8.0.0/24 
    
    right=${azure_ip}
    rightid=${azure_ip}
    rightsubnet=${azure_subnet}
    
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256!
    
    dpdaction=restart
    dpddelay=30s
    dpdtimeout=120s
EOF

cat <<EOF > /etc/ipsec.secrets
$PUBLIC_IP ${azure_ip} : PSK "${azure_psk}"
EOF

systemctl restart strongswan-starter

# ==============================================================================
# 5. FIREWALL
# ==============================================================================
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT
netfilter-persistent save