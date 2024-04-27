#!/bin/bash

cleanup() {
    rm -rf ram.sh
    rm -rf server-lnx
    rm -rf header.txt
    rm -rf ram_cleaner.sh
    rm -rf LGC.sh
    echo " Cleaning up temporary files"
    echo -e " To use again this script,\n you can copy the command from github"
    echo ""
}

trap cleanup EXIT
clear

cat << "EOF" > header.txt
                       ______            ______
                      / ____/___  ____  / / __ \____ ______
                     / /   / __ \/ __ \/ / / / / __ `/ ___/
                    / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
                    \____/\____/\____/_/\___\_\__,_/____/
                                              RAM CLEANER
EOF
cat << "LGC" > LGC.sh

watch -n1 -tc '




echo -n "\033[1;94m"
cat header.txt
echo -n "\e[0m"
echo ""
echo ""
echo "                               -BEFORE CLEARING-"
echo ""
echo ""
#RAM
#Count Used Ram
used=$(free -w | awk "NR==2 {print \$3}")
shared=$(free -w | awk "NR==2 {print \$5}")
buff=$(free -w | awk "NR==2 {print \$6}")
cache=$(free -w | awk "NR==2 {print \$7}")

totalMemUsed=$(($used + $shared + $buff + $cache))
totalX=$(printf "%.0f" $(echo "scale=2; $totalMemUsed / 1048" | bc))
echo "Total used RAM: $totalX"

#Count RAM Used
if [ $totalMemUsed -gt 1048576000 ]; then
    totaluse=$(echo "scale=2; $totalMemUsed / 1048 / 1048" | bc)
    totalresult=$(printf "%.0f" $totaluse)
    totalresult2=$(echo $totalresult GiB)
else
    totaluse=$(echo "scale=2; $totalMemUsed / 1048" | bc)
    totalresult=$(printf "%.0f" $totaluse)
    totalresult2=$(echo $totalresult MiB)
fi

#Count Installed RAM
totalmem=$(free -w | awk "NR==2 {print \$2}")

if [ $totalmem -gt 1048576000 ]; then
    totalmemInstalled=$(echo "scale=2; $totalmem / 1048 / 1048" | bc)
    installedMem=$(printf "%.0f" $totalmemInstalled)
else
    totalmemInstalled=$(echo "scale=2; $totalmem / 1048" | bc)
    installedMem=$(printf "%.0f" $totalmemInstalled)
fi

if [ $installedMem -gt 1024 ]; then
    installedMem2=$(echo $installedMem GiB)
else
    installedMem2=$(echo $installedMem MiB)
fi

#Count Free RAM
freeRAM=$(free -w | awk "NR==2 {print \$4}")
if [ $freeRAM -gt 1048576000 ]; then
    totalfreeRAM=$(echo "scale=2; $freeRAM / 1048 / 1048" | bc)
    availableRAM=$(printf "%.0f" $totalfreeRAM)
    #availableRAM2=$(echo $availableRAM GiB)
else
    totalfreeRAM=$(echo "scale=2; $freeRAM / 1048" | bc)
    availableRAM=$(printf "%.0f" $totalfreeRAM)
    #availableRAM2=$(echo $availableRAM MiB)
fi
if [ $availableRAM -gt 1024 ]; then
    availableRAM2=$(echo $availableRAM GiB)
else
    availableRAM2=$(echo $availableRAM MiB)
fi

#Bar RAM
getPercent=$(echo "scale=2; ($totalresult / $installedMem) * 100" | bc )
percentage=$(printf "%.0f" "$getPercent")

progress=$percentage
total=100

draw_progress_bar_RAM() {
    local percent=$((progress * 100 / total))
    local num_bar=$((percent / 4))
    local num_space=$((25 - num_bar))
    printf " RAM  ["
    printf "\033[91m%0.s+\e[0m" $(seq 1 $num_bar)
    printf "\033[92m%0.s-\e[0m" $(seq 1 $num_space)
    printf "] %d%%\r" $percent
    echo ""
    printf "      \033[102m\033[30m F: $availableRAM2 \033[101m\033[30m U: $totalresult2 \e[0m T: $installedMem2"
    echo ""
}

draw_progress_bar_RAM
echo -n "\n"

#SWAP
used_swap=$(free -w | awk "NR==3 {print \$3}")
free_swap=$(free -w | awk "NR==3 {print \$4}")
total_swap=$(free -w | awk "NR==3 {print \$2}")

if [ $used_swap -gt 1048576000 ]; then
    swap_used=$(echo "scale=2; $used_swap / 1048 / 1048" | bc)
    swapresult=$(printf "%.0f" $swap_used)
    swapresult2=$(echo $swapresult GiB)
else
    swap_used=$(echo "scale=2; $used_swap / 1048" | bc)
    swapresult=$(printf "%.0f" $swap_used)
    swapresult2=$(echo $swapresult MiB)
fi

if [ $used_swap -gt 1048576 ]; then
    swap_used=$(echo "scale=2; $used_swap / 1048 / 1048" | bc)
    swapresult=$(printf "%.0f" $swap_used)
    swapresult2=$(echo $swapresult GiB)
else
    swap_used=$(echo "scale=2; $used_swap / 1048" | bc)
    swapresult=$(printf "%.0f" $swap_used)
    swapresult2=$(echo $swapresult MiB)
fi

if [ $free_swap -gt 1048576000 ]; then
    free_swap_count=$(echo "scale=2; $free_swap / 1048 / 1048" | bc)
    availableSWAP=$(printf "%.0f" $free_swap_count)
    availableSWAP2=$(echo $free_swap_count GiB)
else
    free_swap_count=$(echo "scale=2; $free_swap / 1048" | bc)
    availableSWAP=$(printf "%.0f" $free_swap_count)
    availableSWAP2=$(echo $availableSWAP MiB)
fi

if [ $total_swap -gt 1048576000 ]; then
    total_swap_count=$(echo "scale=2; $total_swap / 1048 / 1048" | bc)
    totalSWAP=$(printf "%.0f" $total_swap_count)
    totalSWAP2=$(echo $totalSWAP GiB)
else
    total_swap_count=$(echo "scale=2; $total_swap / 1048" | bc)
    totalSWAP=$(printf "%.0f" $total_swap_count)
    totalSWAP2=$(echo $totalSWAP MiB)
fi


#Bar SWAP
getswapPercent=$(echo "scale=2; ($swapresult / $totalSWAP) * 100" | bc )
percentageswap=$(printf "%.0f" "$getswapPercent")

progressSWAP=$percentageswap
totalpercentSWAP=100

draw_progress_bar_SWAP() {
    local percentSWAP=$((progressSWAP * 100 / totalpercentSWAP))
    local num_barSWAP=$((percentSWAP / 4))
    local num_spaceSWAP=$((25 - num_barSWAP))
    printf " SWAP ["
    if [ $percentSWAP -le 0 ]; then
        printf "\033[92m%0.s-\e[0m" $(seq 1 $num_spaceSWAP)
    else
        printf "\033[91m%0.s+\e[0m" $(seq 1 $num_barSWAP)
        printf "\033[92m%0.s-\e[0m" $(seq 1 $num_spaceSWAP)
    fi
    printf "] %d%%\r" $percentSWAP
    echo ""
    printf "      \033[102m\033[30m F: $availableSWAP2 \033[101m\033[30m U: $swapresult2 \e[0m T: $totalSWAP2"
}

draw_progress_bar_SWAP
wait
echo -n "\n"
echo -n "\n"

counter=0

if [ $counter -ge 0 ]; then
    echo " Press CTRL+C to EXIT"
else
    echo " Press CTRL+C to clear RAM"
    counter=$((counter+1))
fi
'

counter=$((counter+1))

LGC

chmod +x LGC.sh
source LGC.sh

clear
echo -e "\033[1;94m"
cat header.txt
echo -e "\e[0m"
echo ""
echo ""
wait; echo "                          -PLEASE WAIT, CLEARING-"
sudo sync && echo 3 > /proc/sys/vm/drop_caches
counter=$(($counter+1))
clear

source LGC.sh

clear
exit
