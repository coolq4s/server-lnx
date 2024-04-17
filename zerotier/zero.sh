#!bin/bash

clear

echo -e "\e[31m"
cat << "EOF"
    ______            ______
   / ____/___  ____  / / __ \____ ______
  / /   / __ \/ __ \/ / / / / __ `/ ___/
 / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
 \____/\____/\____/_/\___\_\__,_/____/
EOF


#Mencari variabel net.ipv4.ip_forward dalam sysctl.conf
if grep -q '^net.ipv4.ip_forward' /etc/sysctl.conf; then
    #Menampilkan nilai variabel dan menanyakan untuk mengubahnya
    current_value=$(grep '^net.ipv4.ip_forward' /etc/sysctl.conf)
    echo -e "\e[0m Value of net.ipv4.ip_forward is : \n \e[97m$current_value"
    read -p "Input value net.ipv4.ip_forward \n 0 = Disable \n 1 = Enable \n\e[92m Type : " new_val>

    #Menghapus tanda pagar jika ada
    sudo sed -i '/^net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf

    #Jika variabel tidak ada di akhir file, tambahkan baris baru
    if [ -z "$current_value" ]; then
        echo "net.ipv4.ip_forward=$new_value" | sudo tee -a /etc/sysctl.conf
    else
        # Ubah nilai variabel sesuai dengan input pengguna
        sudo sed -i "s/^net.ipv4.ip_forward=.*/net.ipv4.ip_forward=$new_value/g" /etc/sys>
    fi

else
    #Jika tidak ditemukan, tambahkan baris baru di akhir file
    read -p "Variabel net.ipv4.ip_forward tidak ditemukan Masukkan nilai baru (0 atau 1):>
    echo "net.ipv4.ip_forward=$new_value" | sudo tee -a /etc/sysctl.conf
fi

# Terapkan perubahan ke kernel
# sudo sysctl -p