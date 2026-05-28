#!/bin/bash

# 0 For DEBUG / TEST only : 
echo "ubuntu:Kodeord1" | chpasswd

# 1. IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# ==============================================================================
# 2. Install packets.   Disable popup
# ==============================================================================
export DEBIAN_FRONTEND=noninteractive

# Pre-set answer for iptables-persistent, so popup is avoided
echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | debconf-set-selections

# silent install
apt-get update
apt-get install -y wireguard strongswan iptables-persistent


# Get public ip
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
    uniqueids=yes

conn azure-s2s
    authby=secret
    auto=start
    type=tunnel
    keyexchange=ikev2
    
    # Local side
    left=%any
    leftid=$PUBLIC_IP
    leftsubnet=${ovh_subnet},10.8.0.0/24 
    
    # Azure side
    right=${azure_ip}
    rightid=${azure_ip}
    rightsubnet=${azure_subnet}
    
    # De crypto-indstillinger der virkede!
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256!
    
    dpdaction=restart
    dpddelay=30s
    dpdtimeout=120s
EOF

cat <<EOF > /etc/ipsec.secrets
$PUBLIC_IP ${azure_ip} : PSK "${azure_psk}"
EOF

systemctl enable strongswan-starter
systemctl restart strongswan-starter

# ==============================================================================
# 5. FIREWALL
# ==============================================================================
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT

# Allow forwarding between azure and Wireguard
iptables -A FORWARD -s ${azure_subnet} -j ACCEPT
iptables -A FORWARD -d ${azure_subnet} -j ACCEPT
netfilter-persistent save