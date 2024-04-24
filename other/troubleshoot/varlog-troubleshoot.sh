#!/bin/sh
cleanup() {
    rm -rf header.txt
    rm -rf server-lnx
    rm -rf varlog-troubleshoot.sh
    echo " Cleaning up temporary files"
    echo " To try again this script,\n you can copy the command from github"
    echo ""
}

trap cleanup EXIT

clear

echo "\e[92m"
cat << "EOF" > header.txt
    ______            ______
   / ____/___  ____  / / __ \____ ______
  / /   / __ \/ __ \/ / / / / __ `/ ___/
 / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
 \____/\____/\____/_/\___\_\__,_/____/
                           VAR/LOG FIXER
EOF
cat header.txt
sleep 1s

echo ""
echo ""

if grep -qE 'weekly|daily|monthly|yearly' /etc/logrotate.conf; then
    #Menampilkan nilai variabel dan menanyakan untuk mengubahnya
    current_value=$(grep -A 1 -E '^[^#]*weekly|daily|monthly|yearly' /etc/logrotate.conf)
    echo "\e[0m Rotate log files found \e[33m$current_value\e[0m"
    echo ""
    echo "Choose rotate log duration:"
    echo "\e[92m 1. Weekly"
    echo "\e[0m 2. Daily"
    echo "\e[93m 3. Monthly"
    echo "\e[91m 4. Yearly"
    echo "\e[0m"
    read -p " Type number (1-4): " option_logrotate_duration
    if ! [ "$option_logrotate_duration" -ge 1 -a "$option_logrotate_duration" -le 4 ]; then
        echo "\e[91mOnly number 1-4 can be allowed."
        exit 1
    fi
    case $option_logrotate_duration in
        1) logrotate_interval="weekly";;
        2) logrotate_interval="daily";;
        3) logrotate_interval="monthly";;
        4) logrotate_interval="yearly";;
    esac

    echo " Logrotate interval now is\e[92m $logrotate_interval"
    
#    echo -e "\e[0m Input new value "
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
    echo "\e[91m"
    echo " Value log files not found"
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