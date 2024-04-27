#!/bin/bash
clear
cleanup() {
    clear
    rm -rf swap_resize.sh
    rm -rf server-lnx
    rm -rf header.txt
    echo " Cleaning up temporary files"
    echo -e " To use again this script,\n you can copy the command from github"
    echo ""
}

trap cleanup EXIT
clear
echo "\e[96m"
cat << "EOF" > header.txt
                       ______            ______
                      / ____/___  ____  / / __ \____ ______
                     / /   / __ \/ __ \/ / / / / __ `/ ___/
                    / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
                    \____/\____/\____/_/\___\_\__,_/____/
                                              RAM CLEANER
EOF




swap_size=$(free -h | awk "NR==3 {print \$2}")
echo "\e[92m"
echo "Current SWAP size : $swap_size"
echo "\e[0m"
read -p " Input SWAP size you need (MB):" input_swap
SWAP_SIZE_MB=$input_swap

# Lokasi swapfile
SWAP_FILE="/swapfile"

# Hapus swapfile lama jika ada
sudo swapoff $SWAP_FILE
rm -rf $SWAP_FILE

# Buat swapfile baru dengan ukuran yang diinginkan
sudo fallocate -l ${SWAP_SIZE_MB}M $SWAP_FILE

# Set izin file
sudo chmod 600 $SWAP_FILE

# Format swapfile
sudo mkswap $SWAP_FILE

# Aktifkan swapfile
sudo swapon $SWAP_FILE

# Tambahkan swapfile ke /etc/fstab untuk mempertahankan pengaturan setiap kali sistem boot
echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
