#!/bin/sh
cleanup() {
    clear
    rm -rf header.txt
    rm -rf server-lnx
    rm -rf varlog-troubleshoot.sh
    echo ""
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

if grep -qE 'hourly|weekly|daily|monthly|yearly' /etc/logrotate.conf; then
    #Menampilkan nilai variabel dan menanyakan untuk mengubahnya
    current_value=$(grep -A 0 -E '^#*weekly|hourly|daily|monthly|yearly' /etc/logrotate.conf)
    echo "\e[0m Rotate log files found \e[33m$current_value\e[0m"
    echo ""
    echo " Choose rotate log duration:"
    echo "\e[92m 1. Hourly"
    echo "\e[0m 2. Daily"
    echo "\e[93m 3. Weekly"
    echo "\e[93m 4. Monthly"
    echo "\e[91m 5. Yearly"
    echo "\e[0m"
    read -p " Type number (1-5): " option_logrotate_duration
    if [ -z "$option_logrotate_duration" ]; then
        echo "\e[101m\e[97m Input is blank. Kill script.\e[0m"
        sleep 5s
        exit
    fi
    if ! [ "$option_logrotate_duration" -ge 1 -a "$option_logrotate_duration" -le 5 ] 2>/dev/null; then
        echo "\e[101m\e[97m Only number (1-5) can be allowed. Kill script.\e[0m"
        sleep 5s
        exit
    fi
    case $option_logrotate_duration in
        1) logrotate_interval="hourly";;
        2) logrotate_interval="daily";;
        3) logrotate_interval="weekly";;
        4) logrotate_interval="monthly";;
        5) logrotate_interval="yearly";;
    esac

    echo " Logrotate interval now is\e[92m $logrotate_interval\e[0m"
    sudo sed -i "s/^$current_value.*/$logrotate_interval/g" /etc/logrotate.conf
    sleep 5s
    clear
    echo "\e[92m"
    cat header.txt
    sleep 1s
    echo ""
    echo ""
    var_log_size=$(df -BM /var/log | tail -n 1 | awk '{print $2}' | sed 's/[MG]//')
    var_log_size_Human=$(df -BM /var/log | tail -n 1 | awk '{print $2}')
    echo "$var_log_size"
    echo "\e[0m Size log you want."
    echo "\e[33m I suggest, use half from your\n total partition /var/log \e[0m"
    echo ""
    echo " Your size partition /var/log is:\e[92m $var_log_size_Human\e[0m"
    read -p " Size : " log_size
    if [ -z "$log_size" ]; then
        echo "\e[101m\e[97m Input is blank. Kill script.\e[0m"
        sleep 5s
        exit
    fi
    if [ "$log_size" -gt "$var_log_size" ]; then
        echo "\e[101m\e[97m The number entered is greater than\n the size of /var/log partition.\n Exiting script.\e[0m"
        sleep 5s
        exit 1
    fi
    log_size="${log_size}M"
    echo "$log_size"
    sudo sed -i "\$asize $log_size" /etc/logrotate.conf
    sudo sed -i "\$acompress" /etc/logrotate.conf
    sleep 5s
    exit
    
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