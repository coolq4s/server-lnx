#!/bin/bash

# Ukuran swap yang diinginkan dalam MB
SWAP_SIZE_MB=2048

# Lokasi swapfile
SWAP_FILE="/swapfile"

# Hapus swapfile lama jika ada
sudo swapoff $SWAP_FILE

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
