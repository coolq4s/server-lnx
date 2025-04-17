#!/bin/bash

# Gunakan bash untuk fitur yang lebih reliable

cleanup() {
    clear
    rm -f header.txt
    rm -f Install-AGH.sh
    rm -rf AdGuardHome
    rm -f AdGuardHome_linux_arm64.tar.gz
    
    echo -e "\nCleaning up temporary files"
    echo "To try again this script, you can copy the command from github"
    echo ""
}

trap cleanup EXIT

clear

# Pastikan direktori kerja writable
WORKDIR=$(dirname "$0")
cd "$WORKDIR" || { echo "Failed to change directory"; exit 1; }

# Buat header.txt dengan cara yang lebih reliable
cat > header.txt <<'HEADER_EOF'
    ______            ______
   / ____/___  ____  / / __ \____ ______
  / /   / __ \/ __ \/ / / / / __ `/ ___/
 / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
 \____/\____/\____/_/\___\_\__,_/____/
                           AGH INSTALLER
HEADER_EOF

# Verifikasi file berhasil dibuat
if [ ! -f "header.txt" ]; then
    echo "Error: Failed to create header file!"
    exit 1
fi

# Tampilkan header dengan warna
echo -e "\e[92m"
cat header.txt
echo -e "\e[0m"

sleep 1

echo -e "\nDownloading AGH package..."
if ! wget -q --show-progress https://static.adguard.com/adguardhome/release/AdGuardHome_linux_arm64.tar.gz; then
    echo "Download failed!"
    exit 1
fi

clear
echo -e "\e[92m"
cat header.txt
echo -e "\e[0m"

echo -e "\nExtracting AGH Package..."
tar xvf AdGuardHome_linux_arm64.tar.gz || { echo "Extraction failed!"; exit 1; }
echo "Extracted successfully"

cd AdGuardHome/ || { echo "Cannot enter AdGuardHome directory"; exit 1; }

clear
echo -e "\e[92m"
cat header.txt
echo -e "\e[0m"

echo -e "\nInstalling AGH Component..."
./AdGuardHome -s install || { echo "Installation failed!"; exit 1; }

clear
echo -e "\e[92m"
cat header.txt
echo -e "\e[0m"

echo -e "\nInstallation Done!"
sleep 2
exit
