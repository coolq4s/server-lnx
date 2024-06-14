#!/bin/bash

# Mengambil konten website dan mengekstrak IP
curl -s https://m.freevpn4you.net/l2tp-ipsec.php | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | sort -u > /IP/IP.txt
# Menginisialisasi repositori baru
git init
# Menambahkan IP.txt ke repositori
git add /IP/IP.txt
# Melakukan commit perubahan
git commit -m "Update IP"

# Mengatur remote origin ke repositori GitHub Anda
git remote add origin git@github.com:coolq4s/IP.git

# Mengirim perubahan ke GitHub
git push -u origin main