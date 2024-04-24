#!/bin/sh
cleanup() {
    rm -rf header.txt
    rm -rf server-lnx
    rm -rf varlog-troubleshoot.sh
    echo " Cleaning up temporary files"
    echo -e " To try again this script,\n you can copy the command from github"
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

clear
if grep -E 'weekly|daily|monthly|yearly' /etc/logrotate.conf; then
    #Menampilkan nilai variabel dan menanyakan untuk mengubahnya
    current_value=$(grep 'weekly|daily|monthly|yearly' /etc/sysctl.conf)
    echo -n"\e[0m Value rotate log files: \e[92m \n $current_value\n"
    echo ""
#    echo -e " Note : If first character has # \n it is disabled, press 1 to actived"
#    echo -e "\e[0m Input new value for IPv4 Forwarding"
#    echo -e "\e[0m 0 = Disable"
#    echo -e "\e[0m 1 = Active"
#    new_value=""
#    while [ -z "$new_value" ]; do
#        read -p " Type : " new_value
#        if [ -z "$new_value" ]; then
#            echo -e "\e[0m\033[91m Error : Cannot blank \e[0m"
#        fi
#    done
#    #Menghapus tanda pagar jika ada
#    sudo sed -i '/^#*net.ipv4.ip_forward/s/^#*//g' /etc/sysctl.conf

#    #Jika variabel tidak ada di akhir file, tambahkan baris baru
#    if [ -z "$current_value" ]; then
#        echo "net.ipv4.ip_forward=$new_value" | sudo tee -a /etc/sysctl.conf > /dev/null
#    else
#        # Ubah nilai variabel sesuai dengan input pengguna
#        sudo sed -i "s/^net.ipv4.ip_forward=.*/net.ipv4.ip_forward=$new_value/g" /etc/sysctl.conf
#    fi
#    sleep 2s
else
    #Jika tidak ditemukan, tambahkan baris baru di akhir file
    echo  -e "\033[91m"
    echo -e " Value log files not found"
#    echo -e "\e[0m Input new value for IPv4 Forwarding"
#    echo -e "\e[0m 0 = Disable"
#    echo -e "\e[0m 1 = Active"
#    new_value=""
#    while [ -z "$new_value" ]; do
#        read -p " Type : " new_value
#        if [ -z "$new_value" ]; then
#            echo -e "\e[0m\033[91m Error : Cannot blank \e[0m"
#        fi
#    done
#    echo "net.ipv4.ip_forward=$new_value" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

exit