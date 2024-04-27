#!/bin/sh
clear
cleanup() {
    clear
    rm -rf swap_resize.sh
    rm -rf server-lnx
    rm -rf header.txt
    echo " Cleaning up temporary files"
    echo " To use again this script,\n you can copy the command from github"
    echo ""
}

trap cleanup EXIT
trap SIGINT
trap cleanup SIGQUIT
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
cat header.txt
echo ""
echo ""
swap_size=$(free -h | awk "NR==3 {print \$2}")
echo "\e[102m\e[97m"
echo "Current SWAP size : $swap_size"
echo "\e[0m"
input_swap=""
while [ -z "$input_swap" ]; do
    if [ ]
    read -p " Input SWAP size you need (MB):" input_swap
done
SWAP_SIZE_MB=$input_swap

SWAP_FILE="/swapfile"

sudo swapoff $SWAP_FILE
rm -rf $SWAP_FILE

sudo fallocate -l ${SWAP_SIZE_MB}M $SWAP_FILE

#swap process
sudo chmod 600 $SWAP_FILE
sudo mkswap $SWAP_FILE
sudo swapon $SWAP_FILE

echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab

sleep 2
exit