#!bin/bash

clear

echo -e "\e[31m"
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
cat header.txt
echo ""
echo ""

# Eksekusi perintah dan gunakan AWK untuk mengekstrak nilai machineid
machineid=$(zerotier-cli status | awk '{print $3}')

# Tampilkan nilai machineid
echo "Machine ID: $machineid"

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
    echo " Done"
fi

# Terapkan perubahan ke kernel
# sudo sysctl -p

rm -rf header.txt