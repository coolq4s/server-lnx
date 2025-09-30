#!/bin/bash

cleanup() {
    rm -rf header.txt
    rm -rf server-lnx
    rm -rf zero.sh
    echo " Cleaning up temporary files"
    echo ""
    echo ""
    echo -e " To try again this script,\n you can copy the command from github"
    echo ""
    echo ""
}

trap cleanup EXIT

clear

echo -e "\033[1;94m"
cat << "EOF" > header.txt
    ______            ______
   / ____/___  ____  / / __ \____ ______
  / /   / __ \/ __ \/ / / / / __ `/ ___/
 / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
 \____/\____/\____/_/\___\_\__,_/____/
                      ZEROTIER INSTALLER
EOF
cat header.txt
sleep 1s

echo ""
echo ""

curl -s https://install.zerotier.com | sudo bash
wait
clear
echo -e "\033[1;94m"
cat header.txt
echo ""
echo ""
echo -e "\e[0m Input your Network ID \n See in\033[33m ZeroTier Dashboard\e[0m\033[49m\e[0m"
netID=""
while [ -z "$netID" ]; do
    read -p " Type : " netID
    if [ -z "$netID" ]; then
        echo -e "\e[0m\033[91m Error : Cannot blank \e[0m"
    fi
done
networkID=$(sudo zerotier-cli join $netID)
if echo "$networkID" | grep -q "invalid"; then
    echo -e "\033[91m Invalid Network ID, force exit"
    exit
else
    echo ""
    echo -e "\e[92m $netID is valid"
fi 
zerotierstatus=$(sudo zerotier-cli listnetworks)
if echo "$zerotierstatus" | grep -o "200 listnetworks $netID" > /dev/null; then
    echo -e "\e[92m $netID has Connected"
else
    echo -e "\033[91m Not Connected"
    exit
fi
echo ""
echo ""
# Get ZeroTier interface and internet interface
echo -e "\e[0m Input your interface using internet, \n you can find with command\e[35m ip addr \e[0m"

physical_iface=""
while [ -z "$physical_iface" ]; do
    read -p " Type : " physical_iface
    if [ -z "$physical_iface" ]; then
        echo -e "\e[0m\033[91m Error : Cannot blank \e[0m"
    fi
done

# Method yang lebih reliable untuk mendapatkan interface ZeroTier
zerotieriface=$(ip link show | grep -o 'zt[0-9a-zA-Z]*' | head -1)
if [ -z "$zerotieriface" ]; then
    # Jika tidak ditemukan zt*, cari interface dengan nama panjang ZeroTier
    zerotieriface=$(ip link show | grep -o 'zt[^[:space:]]*' | head -1)
fi

PHY_IFACE=$physical_iface
ZT_IFACE=$zerotieriface

clear
echo -e "\033[1;94m"
cat header.txt
echo ""
echo ""

# =============================================
# BAGIAN BARU: INPUT NETWORK LOKAL
# =============================================

echo -e "\e[0m Configure local networks for routing"
echo -e "\e[0m Enter local networks you want to access via ZeroTier"
echo -e "\e[0m Format: 192.168.1.0/24 (one per line, empty to finish)"

LOCAL_NETWORKS=()
while true; do
    read -p " Enter network CIDR (e.g., 192.168.1.0/24): " network
    if [ -z "$network" ]; then
        break
    fi
    # Validasi format CIDR sederhana
    if [[ $network =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        LOCAL_NETWORKS+=("$network")
        echo -e "\e[92m Added: $network"
    else
        echo -e "\e[91m Invalid format. Use format: 192.168.1.0/24"
    fi
done

# Jika tidak ada network yang dimasukkan, gunakan default
if [ ${#LOCAL_NETWORKS[@]} -eq 0 ]; then
    echo -e "\e[93m No networks specified. Using defaults: 10.10.10.0/24, 10.10.100.0/24"
    LOCAL_NETWORKS=("10.10.10.0/24" "10.10.100.0/24")
fi

echo ""
echo -e "\e[92m Networks to be routed:"
for network in "${LOCAL_NETWORKS[@]}"; do
    echo "  - $network"
done

echo ""
read -p " Press Enter to continue..."

# Eksekusi perintah dan gunakan AWK untuk mengekstrak nilai machineid
machineid=$(sudo zerotier-cli status | awk '{print $3}')

# Tampilkan nilai machineid
echo -e "\e[92m Your machine ID: \e[92m$machineid"

# Mencari variabel net.ipv4.ip_forward dalam sysctl.conf
if grep -q '^#*net.ipv4.ip_forward' /etc/sysctl.conf; then
    # Menampilkan nilai variabel dan menanyakan untuk mengubahnya
    current_value=$(grep '^#*net.ipv4.ip_forward' /etc/sysctl.conf)
    echo -e "\e[0m Value net.ipv4.ip_forward is: \e[92m \n $current_value\n"
    echo -e ""
    echo -e " Note : If first character has # \n it is disabled, press 1 to actived"
    echo -e "\e[0m Input new value for IPv4 Forwarding"
    echo -e "\e[0m 0 = Disable"
    echo -e "\e[0m 1 = Active"
    new_value=""
    while [ -z "$new_value" ]; do
        read -p " Type : " new_value
        if [ -z "$new_value" ]; then
            echo -e "\e[0m\033[91m Error : Cannot blank \e[0m"
        fi
    done
    # Menghapus tanda pagar jika ada
    sudo sed -i '/^#*net.ipv4.ip_forward/s/^#*//g' /etc/sysctl.conf

    # Jika variabel tidak ada di akhir file, tambahkan baris baru
    if [ -z "$current_value" ]; then
        echo "net.ipv4.ip_forward=$new_value" | sudo tee -a /etc/sysctl.conf > /dev/null
    else
        # Ubah nilai variabel sesuai dengan input pengguna
        sudo sed -i "s/^net.ipv4.ip_forward=.*/net.ipv4.ip_forward=$new_value/g" /etc/sysctl.conf
        echo "net.ipv4.ip_forward=$new_value" | sudo tee /etc/sysctl.d/99-ip-forward.conf > /dev/null
        sudo sysctl -p /etc/sysctl.d/99-ip-forward.conf
    fi
    sleep 2s
else
    # Jika tidak ditemukan, tambahkan baris baru di akhir file
    echo  -e "\033[91m"
    echo -e " This line net.ipv4.ip_forward not found"
    echo -e "\e[0m Input new value for IPv4 Forwarding"
    echo -e "\e[0m 0 = Disable"
    echo -e "\e[0m 1 = Active"
    new_value=""
    while [ -z "$new_value" ]; do
        read -p " Type : " new_value
        if [ -z "$new_value" ]; then
            echo -e "\e[0m\033[91m Error : Cannot blank \e[0m"
        fi
    done
    echo "net.ipv4.ip_forward=$new_value" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

# Apply IP forwarding immediately
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

clear
echo -e "\033[1;94m"
cat header.txt
echo ""
echo ""
echo -e "\e[0m"

# Gunakan nftables sebagai pengganti iptables-legacy
echo -e "\e[92m Setting up nftables for ZeroTier routing..."

# Install nftables jika belum ada
if ! command -v nft &> /dev/null; then
    echo -e "\e[93m Installing nftables..."
    sudo apt update
    sudo apt install -y nftables
fi

# Stop iptables services jika ada
sudo systemctl stop iptables 2>/dev/null || true
sudo systemctl disable iptables 2>/dev/null || true

# Enable nftables
sudo systemctl enable nftables 2>/dev/null || true
sudo systemctl start nftables 2>/dev/null || true

# Setup nftables rules
sudo nft flush ruleset 2>/dev/null || true

# =============================================
# BAGIAN ROUTING UNTUK NETWORK LOKAL
# =============================================

# Dapatkan IP ZeroTier device ini
ZT_IP=$(sudo zerotier-cli listnetworks | awk 'NR>2 {print $9; exit}')

echo -e "\e[92m Setting up routing for local networks..."
echo -e "\e[0m ZeroTier IP: $ZT_IP"
echo -e "\e[0m Local Networks to route:"
for network in "${LOCAL_NETWORKS[@]}"; do
    echo "  - $network"
done

# Create NAT table and rules
sudo nft add table ip nat 2>/dev/null || true
sudo nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; } 2>/dev/null

# NAT Rules untuk semua traffic
sudo nft add rule ip nat postrouting oifname "$PHY_IFACE" masquerade 2>/dev/null
sudo nft add rule ip nat postrouting oifname "$ZT_IFACE" masquerade 2>/dev/null

# NAT Rules khusus untuk network lokal
for network in "${LOCAL_NETWORKS[@]}"; do
    sudo nft add rule ip nat postrouting ip saddr $network oifname "$ZT_IFACE" masquerade 2>/dev/null
done

# Create filter table and rules
sudo nft add table ip filter 2>/dev/null || true
sudo nft add chain ip filter forward { type filter hook forward priority 0 \; } 2>/dev/null

# Basic forward rules
sudo nft add rule ip filter forward ct state established,related accept 2>/dev/null
sudo nft add rule ip filter forward iifname "$ZT_IFACE" oifname "$PHY_IFACE" accept 2>/dev/null
sudo nft add rule ip filter forward iifname "$PHY_IFACE" oifname "$ZT_IFACE" accept 2>/dev/null

# =============================================
# RULES KHUSUS UNTUK LOCAL NETWORKS
# =============================================

# Allow traffic dari ZeroTier ke local networks
for network in "${LOCAL_NETWORKS[@]}"; do
    sudo nft add rule ip filter forward iifname "$ZT_IFACE" ip daddr $network accept 2>/dev/null
    sudo nft add rule ip filter forward oifname "$ZT_IFACE" ip saddr $network accept 2>/dev/null
done

# Allow traffic antara local networks melalui ZeroTier
for network in "${LOCAL_NETWORKS[@]}"; do
    sudo nft add rule ip filter forward iifname "$PHY_IFACE" ip daddr $network oifname "$ZT_IFACE" accept 2>/dev/null
    sudo nft add rule ip filter forward iifname "$ZT_IFACE" ip saddr $network oifname "$PHY_IFACE" accept 2>/dev/null
done

# =============================================
# INPUT RULES UNTUK REMOTE ACCESS
# =============================================

# Allow SSH dan management traffic dari ZeroTier
sudo nft add chain ip filter input { type filter hook input priority 0 \; } 2>/dev/null
sudo nft add rule ip filter input iifname "$ZT_IFACE" ct state established,related accept 2>/dev/null
sudo nft add rule ip filter input iifname "$ZT_IFACE" tcp dport {22,80,443,9993} accept 2>/dev/null
sudo nft add rule ip filter input iifname "$ZT_IFACE" udp dport {9993} accept 2>/dev/null

# Save nftables rules
sudo nft list ruleset | sudo tee /etc/nftables.conf > /dev/null

# Jika interface ZeroTier panjang, gunakan pendekatan alternatif
if [ ${#ZT_IFACE} -gt 15 ]; then
    echo -e "\e[93m ZeroTier interface name is too long, using IP-based rules..."
    
    # Flush dan setup ulang dengan IP-based rules
    sudo nft flush ruleset
    
    # NAT rules
    sudo nft add table ip nat
    sudo nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
    sudo nft add rule ip nat postrouting oifname "$PHY_IFACE" masquerade
    
    # NAT untuk setiap network lokal
    for network in "${LOCAL_NETWORKS[@]}"; do
        sudo nft add rule ip nat postrouting ip saddr $network masquerade
    done
    
    # Filter rules
    sudo nft add table ip filter
    sudo nft add chain ip filter forward { type filter hook forward priority 0 \; }
    sudo nft add rule ip filter forward ct state established,related accept
    
    # Rules untuk setiap network lokal
    for network in "${LOCAL_NETWORKS[@]}"; do
        sudo nft add rule ip filter forward ip daddr $network accept
        sudo nft add rule ip filter forward ip saddr $network accept
    done
    
    # Save rules
    sudo nft list ruleset | sudo tee /etc/nftables.conf > /dev/null
fi

# Apply rules
sudo nft -f /etc/nftables.conf 2>/dev/null || true

echo -e "\e[92m NFTables rules applied successfully!"

# =============================================
# INSTRUKSI SETUP ZEROTIER CENTRAL
# =============================================

echo ""
echo -e "\e[93m === IMPORTANT: ZeroTier Central Setup Required ==="
echo -e "\e[0m Please go to https://my.zerotier.com/ and:"
echo ""
echo "1. Select your network: $netID"
echo "2. Go to 'Managed Routes' and ADD:"
echo ""
for network in "${LOCAL_NETWORKS[@]}"; do
    echo "   - Via: $ZT_IP"
    echo "   - Target: $network"
done
echo ""
echo "3. Make sure this device is AUTHORIZED (checked)"
echo "4. Save changes"
echo ""
echo -e "\e[92m After completing these steps, your local networks will be accessible from ZeroTier!"

# Install iptables-persistent untuk backup
echo -e "\e[93m Installing iptables-persistent for backup..."
sudo apt update
sudo apt install -y iptables-persistent

# =============================================
# VERIFICATION
# =============================================

echo ""
echo -e "\e[92m === VERIFICATION ==="
echo -e "\e[0m NFTables Rules:"
sudo nft list ruleset

echo ""
echo -e "\e[0m ZeroTier Status:"
sudo zerotier-cli listnetworks

echo ""
echo -e "\e[0m IP Forwarding: $(cat /proc/sys/net/ipv4/ip_forward)"

echo ""
echo -e "\e[92m === TESTING INSTRUCTIONS ==="
echo -e "\e[0m From another ZeroTier device, test with:"
for network in "${LOCAL_NETWORKS[@]}"; do
    base_ip=$(echo $network | cut -d'/' -f1 | sed 's/0$/1/')
    echo "ping $base_ip"
    echo "ssh user@$base_ip"
done

rm -rf header.txt
echo ""
echo ""
echo -e "\e[92m DONE!"
echo -e "\e[92m ZeroTier routing has been configured for ${#LOCAL_NETWORKS[@]} local networks"
echo -e "\e[0m Remember to setup Managed Routes in ZeroTier Central as instructed above"
echo -e "\e[0m You may need to reboot for all changes to take effect"
echo -e "\e[0m"
sleep 5s
exit
