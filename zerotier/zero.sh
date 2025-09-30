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
# Eksekusi perintah dan gunakan AWK untuk mengekstrak nilai machineid
machineid=$(sudo zerotier-cli status | awk '{print $3}')

# Tampilkan nilai machineid
echo -e "\e[92m Your machine ID: \e[92m$machineid"

#Mencari variabel net.ipv4.ip_forward dalam sysctl.conf
if grep -q '^#*net.ipv4.ip_forward' /etc/sysctl.conf; then
    #Menampilkan nilai variabel dan menanyakan untuk mengubahnya
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
    #Menghapus tanda pagar jika ada
    sudo sed -i '/^#*net.ipv4.ip_forward/s/^#*//g' /etc/sysctl.conf

    #Jika variabel tidak ada di akhir file, tambahkan baris baru
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
    #Jika tidak ditemukan, tambahkan baris baru di akhir file
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

# Create NAT table and rules
sudo nft add table ip nat 2>/dev/null || true
sudo nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; } 2>/dev/null
sudo nft add rule ip nat postrouting oifname "$PHY_IFACE" masquerade 2>/dev/null

# Create filter table and rules
sudo nft add table ip filter 2>/dev/null || true
sudo nft add chain ip filter forward { type filter hook forward priority 0 \; } 2>/dev/null
sudo nft add rule ip filter forward iifname "$ZT_IFACE" oifname "$PHY_IFACE" accept 2>/dev/null
sudo nft add rule ip filter forward iifname "$PHY_IFACE" oifname "$ZT_IFACE" ct state related,established accept 2>/dev/null

# Save nftables rules
if [ -d /etc/nftables.conf ]; then
    sudo nft list ruleset > /tmp/nftables_rules.conf
    sudo mv /tmp/nftables_rules.conf /etc/nftables.conf
else
    sudo nft list ruleset | sudo tee /etc/nftables.conf > /dev/null
fi

# Jika interface ZeroTier panjang, gunakan pendekatan alternatif
if [ ${#ZT_IFACE} -gt 15 ]; then
    echo -e "\e[93m ZeroTier interface name is too long, using alternative method..."
    
    # Dapatkan IP range ZeroTier dari listnetworks
    zt_network_info=$(sudo zerotier-cli listnetworks | grep "$netID")
    zt_ip_range=$(echo "$zt_network_info" | awk '{print $7}' | cut -d'.' -f1-3)
    
    if [ -n "$zt_ip_range" ]; then
        echo -e "\e[92m Using IP range: $zt_ip_range.0/24"
        
        # Flush dan setup ulang dengan IP-based rules
        sudo nft flush ruleset
        
        # NAT rules berdasarkan IP range
        sudo nft add table ip nat
        sudo nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
        sudo nft add rule ip nat postrouting ip saddr $zt_ip_range.0/24 oifname "$PHY_IFACE" masquerade
        
        # Filter rules berdasarkan IP range
        sudo nft add table ip filter
        sudo nft add chain ip filter forward { type filter hook forward priority 0 \; }
        sudo nft add rule ip filter forward ip daddr $zt_ip_range.0/24 ct state established,related accept
        sudo nft add rule ip filter forward ip saddr $zt_ip_range.0/24 accept
        
        # Save rules
        sudo nft list ruleset | sudo tee /etc/nftables.conf > /dev/null
    fi
fi

# Apply rules
sudo nft -f /etc/nftables.conf 2>/dev/null || true

echo -e "\e[92m NFTables rules applied successfully!"
echo -e "\e[0m Current nftables rules:"
sudo nft list ruleset

# Install iptables-persistent hanya untuk backup (optional)
echo -e "\e[93m Installing iptables-persistent for backup..."
sudo apt update
sudo apt install -y iptables-persistent

rm -rf header.txt
echo ""
echo ""
echo -e "\e[92m DONE!"
echo -e "\e[92m ZeroTier routing has been configured using nftables"
echo -e "\e[0m You may need to reboot for all changes to take effect"
echo -e "\e[0m"
sleep 5s
exit
