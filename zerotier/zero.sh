#!bin/bash

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

#apt install zerotier-one
wait
clear
echo -e "\033[1;94m"
cat header.txt
echo ""
echo ""
echo -e "\e[97m Input your Network ID \n See in\033[33m ZeroTier Dashboard\033[39m\033[49m"
read -p " Type : " netID
networkID=$(zerotier-cli join $netID)
if echo "$networkID" | grep -q "invalid"; then
    echo -e "\e[31m Invalid Network ID, force exit"
    #exit
else
    echo ""
    echo -e "\e[92m $netID is valid"
fi 
zerotierstatus=$(zerotier-cli listnetworks)
if ["$zerotierstatus" != "200 listnetworks $netID"]; then
    echo -e "\e[92m $networkID has Connected"
else
    echo -e "\e[31m Not Connected"
fi
echo ""
echo ""
# Get ZeroTier interface and internet interface
echo -e "\e[97m Input your interface using internet, \n you can find with command\e[35m ifconfig \e[97m"

physical_iface=""
while [ -z "$physical_iface" ]; do
    read -p " Type : " input
    if [ -z "$physical_iface" ]; then
        echo -e "\e[0m\e[31m Error : Cannot blank \e[0m"
    fi
done

echo "Anda memasukkan nilai: $input"


read -p " Type : " physical_iface
zerotieriface=$(ifconfig | grep -o 'zt[0-9a-zA-Z]*')

PHY_IFACE=$physical_iface
ZT_IFACE=$zerotierstatus


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
    echo -e "\e[97m Value net.ipv4.ip_forward is: \e[92m \n $current_value\n"
    echo -e ""
    echo -e " Note : If first character has # \n it is disabled, press 1 to actived"
    echo -e "\e[97m Input new value for IPv4 Forwarding"
    echo -e "\e[0m 0 = Disable"
    echo -e "\e[0m 1 = Active"
    read -p " Type : " new_value

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
    echo  -e "\e[31m"
    read -p " This line net.ipv4.ip_forward not found" new_value
    echo -e "\e[97m Input new value for IPv4 Forwarding"
    echo -e "\e[0m 0 = Disable"
    echo -e "\e[0m 1 = Active"
    read -p " Type : " new_value
    echo "net.ipv4.ip_forward=$new_value" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

clear
echo -e "\033[1;94m"
cat header.txt
echo ""
echo ""
echo -e "\e[0m"
iptable_check=$(grep "$PHY_IFACE -j MASQUERADE" /etc/iptables/rules.v4)
if ! [ ! "$iptable_check" ]; then
    # Jalankan perintah yang Anda inginkan jika variabel tidak kosong
    echo "$PHY_IFACE has MASQUERADE"
    # Tambahkan perintah yang ingin Anda jalankan di sini
else
    echo "$PHY_IFACE not MASQUERADE, adding MASQUERADE interface"
    iptables -t nat -A POSTROUTING -o $PHY_IFACE -j MASQUERADE
fi


exit
#iptables -t nat -A POSTROUTING -o $PHY_IFACE -j MASQUERADE
#iptables -A FORWARD -i $ZT_IFACE -o $PHY_IFACE -j ACCEPT
#apt install iptables-persistent
#bash -c iptables-save > /etc/iptables/rules.v4

# Terapkan perubahan ke kernel
# sudo sysctl -p

rm -rf header.txt
echo "DONE"