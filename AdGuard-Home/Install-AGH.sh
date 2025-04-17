#!/bin/sh
cleanup() {
    clear
    echo " Clean up directory before exiting script"
    rm -rf header.txt
    rm -rf server-lnx
    rm -rf Install-AGH.sh
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

wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_arm64.tar.gz
clear
echo "\e[92m"
cat header.txt
sleep 1s
echo ""
echo ""
echo "Extracting AGH Package ..."
tar xvf AdGuardHome_linux_arm64.tar.gz
echo "Extracted"
cd AdGuardHome/
clear
echo "\e[92m"
cat header.txt
sleep 1s
echo ""
echo ""
echo "Installing AGH Component"
./AdGuardHome -s install
clear
echo "\e[92m"
cat header.txt
sleep 1s
echo ""
echo ""
echo "Installing Done"
