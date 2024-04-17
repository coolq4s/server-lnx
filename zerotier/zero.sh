#!bin/bash
clear

echo "\e[31m"
    ______            ______
   / ____/___  ____  / / __ \____ ______
  / /   / __ \/ __ \/ / / / / __ `/ ___/
 / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
 \____/\____/\____/_/\___\_\__,_/____/

echo "\e[0m"


#Mencari variabel net.ipv4.ip_forward dalam sysctl.conf
if grep -q '^net.ipv4.ip_forward' /etc/sysctl.conf; then
    #Menampilkan nilai variabel dan menanyakan untuk mengubahnya
    current_value=$(grep '^net.ipv4.ip_forward' /etc/sysctl.conf)
    echo "\e[97m Current active IP forward : \n\e[92m$current_value"
    read -p "\e[97m Input value of net.ipv4.ip_forward \n 0 = Disable \n 1 = Active) \n\e[92m Type :" new_value

    #Menghapus tanda pagar jika ada
    sudo sed -i '/^net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf
    echo "\e[97m"
    #Jika variabel tidak ada di akhir file, tambahkan baris baru
    if [ -z "$current_value" ]; then
        echo "net.ipv4.ip_forward=\e[92m$new_value\e[0m" | sudo tee -a /etc/sysctl.conf
    else
        #Ubah nilai variabel sesuai dengan input pengguna
        sudo sed -i "s/^net.ipv4.ip_forward=.*/net.ipv4.ip_forward=$new_value/g" /etc/sysctl.conf
    fi

else
    #Jika tidak ditemukan, tambahkan baris baru di akhir file
    read -p "\e[31m net.ipv4.ip_forward Not Found \n\e[92m Input new value \n 0 = Disable \n 1 = Active) \n\e[92m Type : " new_value
    echo "\e[97m net.ipv4.ip_forward=\e[92m$new_value" | sudo tee -a /etc/sysctl.conf
fi


# Terapkan perubahan ke kernel
# sudo sysctl -p