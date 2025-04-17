#!/bin/sh

cleanup() {
    clear
    rm -f header.txt
    rm -rf server-lnx
    rm -f Install-AGH.sh
    echo ""
    echo " Cleaning up temporary files"
    echo " To try again this script, you can copy the command from github"
    echo ""
}

trap cleanup EXIT

clear

# Membuat header.txt dengan format yang benar
cat > header.txt << 'EOF'
    ______            ______
   / ____/___  ____  / / __ \____ ______
  / /   / __ \/ __ \/ / / / / __ `/ ___/
 / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
 \____/\____/\____/_/\___\_\__,_/____/
                           AGH INSTALLER
EOF

# Menampilkan header dengan warna hijau (hanya jika menggunakan bash)
printf "\033[92m"
cat header.txt
printf "\033[0m"  # Reset warna

sleep 1

echo "\n"

wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_arm64.tar.gz
clear
printf "\033[92m"
cat header.txt
printf "\033[0m"
sleep 1
echo "\n"
echo "Extracting AGH Package ..."
sleep 1
tar xvf AdGuardHome_linux_arm64.tar.gz
echo "Extracted"
cd AdGuardHome/ || exit
clear
printf "\033[92m"
cat header.txt
printf "\033[0m"
sleep 1
echo "\n"
echo "Installing AGH Component"
sleep 1
./AdGuardHome -s install
clear
printf "\033[92m"
cat header.txt
printf "\033[0m"
sleep 1
echo "\n"
echo "Installing Done"
sleep 1
exit 0
