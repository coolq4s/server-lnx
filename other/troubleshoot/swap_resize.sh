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
clear
echo ""
echo "\e[96m"
cat << "EOF" > header.txt
                       ______            ______
                      / ____/___  ____  / / __ \____ ______
                     / /   / __ \/ __ \/ / / / / __ `/ ___/
                    / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
                    \____/\____/\____/_/\___\_\__,_/____/
                                              SWAP RESIZE
EOF
cat header.txt
echo ""
echo ""
echo " \e[101m\e[97m            ATTENTION!!!            \e[0m"
echo " \e[101m\e[97m Turning off first your custom swap \e[0m"
echo " \e[101m\e[97m before running this script         \e[0m"

echo ""
echo ""
swap_size=$(free -h | awk "NR==3 {print \$2}")
swap_format=$(echo $swap_size"B")
echo " Current SWAP size : \e[102m\e[30m $swap_format "
echo "\e[0m"
read -p " Swap size you need (1-99999 MB) : " input_swap
SWAP_SIZE_MB=$input_swap
SWAP_FILE="/swapfile"
if [ $input_swap -gt 1 ] >> /dev/null; then
    if grep -qF "$SWAP_FILE none swap sw 0 0" /etc/fstab; then
        clear;
        echo "\e[0m"
        echo "\e[96m"
        cat header.txt
        echo "\e[0m"
        echo ""
        echo ""
        echo " SWAP config already entry, SKIPPING"
        sleep 3
        echo " Adding new SWAP Size"
        sleep 2
        sudo swapoff $SWAP_FILE >> /dev/null
        rm -rf $SWAP_FILE
        sudo fallocate -l ${SWAP_SIZE_MB}M $SWAP_FILE >> /dev/null
        sudo chmod 600 $SWAP_FILE >> /dev/null
        sudo mkswap $SWAP_FILE >> /dev/null
        sudo swapon $SWAP_FILE >> /dev/null
    else
        echo " Adding new SWAP Size"
        sudo swapoff $SWAP_FILE >> /dev/null
        rm -rf $SWAP_FILE
        sudo fallocate -l ${SWAP_SIZE_MB}M $SWAP_FILE >> /dev/null
        sudo chmod 600 $SWAP_FILE >> /dev/null
        sudo mkswap $SWAP_FILE >> /dev/null
        sudo swapon $SWAP_FILE >> /dev/null
        echo " $SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null;
        sleep 5
    fi
    swap_after_extend=$(free -h | awk "NR==3 {print \$2}")
    echo " SWAP from" $swap_size"B resized to "$swap_after_extend"B"
    sleep 7
    echo " Clearing tool cache..."
    sleep 2
    echo " Cleared"
    sleep 1
    read -p " Press any key to continue" PAKTC
else
    clear;
    echo "\e[0m"
    echo "\e[96m"
    cat header.txt
    echo "\e[0m"
    echo ""
    echo ""
    echo " Only number 1-99999, \e[101m\e[97m CLOSE TOOL \e[0m"
    sleep 1
    read -p " Press any key to continue" PAKTC
    exit
fi
echo " DONE, Tool will be CLOSE"
sleep 3
exit