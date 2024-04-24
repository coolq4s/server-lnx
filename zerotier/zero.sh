#!bin/bash

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

echo -e "\033[1;97m"
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

apt install zerotier-one
wait
clear
echo -e "\033[1;97m"
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
networkID=$(zerotier-cli join $netID)
if echo "$networkID" | grep -q "invalid"; then
    echo -e "\033[91m Invalid Network ID, force exit"
    exit
else
    echo ""
    echo -e "\e[92m $netID is valid"
fi 
zerotierstatus=$(zerotier-cli listnetworks)
if echo "$zerotierstatus" | grep -o "200 listnetworks $netID" > /dev/null; then
    echo -e "\e[92m $netID has Connected"
else
    echo -e "\033[91m Not Connected"
    exit
fi
echo ""
echo ""
# Get ZeroTier interface and internet interface
echo -e "\e[0m Input your interface using internet, \n you can find with command\e[35m ifconfig \e[0m"

physical_iface=""
while [ -z "$physical_iface" ]; do
    read -p " Type : " physical_iface
    if [ -z "$physical_iface" ]; then
        echo -e "\e[0m\033[91m Error : Cannot blank \e[0m"
    fi
done

zerotieriface=$(ifconfig | grep -o 'zt[0-9a-zA-Z]*')

PHY_IFACE=$physical_iface
ZT_IFACE=$zerotieriface


clear
echo -e "\033[1;94m"
cat header.txt
echo ""
echo ""
# Eksekusi perintah dan gunakan AWK untuk mengekstrak nilai machineid
machineid=$(zerotier-cli status | awk '{print $3}')

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

clear
echo -e "\033[1;94m"
cat header.txt
echo ""
echo ""
echo -e "\e[0m"
PHY_check=$(grep "$PHY_IFACE -j MASQUERADE" /etc/iptables/rules.v4)
if ! [ ! "$PHY_check" ]; then
    echo -e "\e[92m $PHY_IFACE has MASQUERADE"
else
    echo -e "\033[91m $PHY_IFACE not MASQUERADE, adding MASQUERADE interface"
    iptables -t nat -A POSTROUTING -o $PHY_IFACE -j MASQUERADE
fi
ZT_check=$(grep "$PHY_IFACE -o $ZT_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT" /etc/iptables/rules.v4)
if ! [ ! "$ZT_check" ]; then
    echo -e "\e[92m $ZT_IFACE and $PHY_IFACE has ACCEPT"
else
    echo -e "\033[91m $ZT_IFACE and $PHY_IFACE not found,\n adding ACCEPT interface"
    iptables -A FORWARD -i $PHY_IFACE -o $ZT_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
fi

apt install iptables-persistent
bash -c iptables-save > /etc/iptables/rules.v4


rm -rf header.txt
echo ""
echo ""
echo -e "\e[92m DONE, Reboot please"
echo -e "\e[0m"
sleep 5s
exit