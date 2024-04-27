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
echo " \e[101m\e[97m            ATTENTION!!!            \e[0m"
echo " \e[101m\e[97m Turning off first your custom swap \e[0m"
echo " \e[101m\e[97m before running this script         \e[0m"

SWAP_SIZE_MB=$input_swap
SWAP_FILE="/swapfile"

swap_size=$(free -h | awk "NR==3 {print \$2}")
echo " Current SWAP size : \e[102m\033[30m$swap_size"
echo "\e[0m"

input_swap=""
read -p " Swap size you need (MB) : " input_swap
if ! [[ $input_swap =~ ^[0-9]+$ ]]; then
    echo " ERR: Masukkan harus berupa angka."
    read " Continue to exit"
else
    continue
fi
if ((input_swap >= 1 && input_swap <= 99999)); then
    echo " Input yang valid: $input_s"
else
    echo " Input harus berada dalam rentang antara 1 hingga 99999."
    exit
fi

#swap process
if ! [[ $input_swap =~ ^[0-9]+$ ]]; then
    if grep -qF "$SWAP_FILE none swap sw 0 0" /etc/fstab; then
        echo " Baris sudah ada dalam /etc/fstab"
    else
        sudo swapoff $SWAP_FILE
        rm -rf $SWAP_FILE
        sudo fallocate -l ${SWAP_SIZE_MB}M $SWAP_FILE
        sudo chmod 600 $SWAP_FILE
        sudo mkswap $SWAP_FILE
        sudo swapon $SWAP_FILE
        echo " $SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null
        echo " Baris berhasil ditambahkan ke /etc/fstab"
    fi
else
    exit
fi

#echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab

sleep 2
exit