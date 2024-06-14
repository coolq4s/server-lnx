#!/bin/bash

# URL halaman web yang berisi IP
URL="https://m.freevpn4you.net/l2tp-ipsec.php"
# Path ke direktori lokal repositori
REPO_PATH="/path/to/your/repoIP"
# Nama file untuk menyimpan IP
IP_FILE="ips.txt"

# Ambil IP dari halaman web
IP_LIST=$(curl -s "$URL" | grep -oP '<td>\d+\.\d+\.\d+\.\d+</td>' | sed -e 's/<td>//g' -e 's/<\/td>//g')

# Simpan IP ke file lokal
echo "$IP_LIST" > "$REPO_PATH/IP/$IP_FILE"

# Masuk ke direktori repositori
cd "$REPO_PATH" || exit