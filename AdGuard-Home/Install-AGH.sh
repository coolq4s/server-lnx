#!/bin/sh
cleanup() {
    clear
    # Kembali ke direktori awal script dijalankan
    cd ..
    rm -rf "header.txt"
    rm -rf server-lnx
    rm -rf Install-AGH.sh
    echo ""
    echo " Cleaning up temporary files"
    echo " To try again this script,\n you can copy the command from github"
    echo ""
    echo "\033[0m"
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
                           AGH INSTALLER
EOF
# Verifikasi file berhasil dibuat
if [ ! -f "header.txt" ]; then
    echo "Error: Failed to create header file!"
    exit 1
fi

#Load Header
cat "header.txt"
sleep 1s

echo ""
echo ""

echo "\nDownloading AGH package..."
if ! wget -q --show-progress https://static.adguard.com/adguardhome/release/AdGuardHome_linux_arm64.tar.gz; then
    echo "Download failed!"
    exit 1
fi
clear
echo "\e[92m"
cat "header.txt"
sleep 1s
echo ""
echo ""

echo "\nExtracting AGH Package..."
sleep 1s
tar xvf AdGuardHome_linux_arm64.tar.gz || { echo "Extraction failed!"; exit 1; }
echo "Extracted successfully"
sleep 1s
cd AdGuardHome/ || { echo "Cannot enter AdGuardHome directory"; exit 1; }
sleep 1s
echo "\nInstalling AGH Component..."
sleep 2s
./AdGuardHome -s install || { echo "Installation failed!"; exit 1; }
echo "AGH Installed"
sleep 5s
clear
echo "Wait.. Exiting Program"
sleep 2s
clear
exit
