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

#Count RAM Used
if [ $totalMemUsed -gt 1048576000 ]; then
    totaluse=$(echo "scale=2; $totalMemUsed / 1048 / 1048" | bc)
    totalresult=$(printf "%.1f" $totaluse)
    #totalresult2=$(echo $totalresult GiB)
else
    totaluse=$(echo "scale=2; $totalMemUsed / 1048" | bc)
    totalresult=$(printf "%.0f" $totaluse)
    #totalresult2=$(echo $totalresult MiB)
fi
if [ $totalresult -gt 1024 ]; then
    totalresult2=$(printf "%.2f GiB" $(echo "scale=2; $totalresult / 1024" | bc))
else
    totalresult2=$(echo $totalresult MiB)
fi



#Count Installed RAM
totalmem=$(free -w | awk "NR==2 {print \$2}")

if [ $totalmem -gt 1048576000 ]; then
    totalmemInstalled=$(echo "scale=2; $totalmem / 1048 / 1048" | bc)
    installedMem=$(printf "%.f" $totalmemInstalled)
else
    totalmemInstalled=$(echo "scale=2; $totalmem / 1048" | bc)
    installedMem=$(printf "%.0f" $totalmemInstalled)
fi

if [ $installedMem -gt 1024 ]; then
    installedMem2=$(printf "%.2f GiB" $(echo "scale=2; $installedMem / 1024" | bc))
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
    availableRAM2=$(printf "%.2f GiB" $(echo "scale=2; $availableRAM / 1024" | bc))
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
    printf "] $percent%%"
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

#Count used swap
if [ $used_swap -gt 1048576000 ]; then
    swap_used=$(echo "scale=2; $used_swap / 1048 / 1048" | bc)
    swapresult=$(printf "%.0f" $swap_used)
    #swapresult2=$(echo $swapresult GiB)
else
    swap_used=$(echo "scale=2; $used_swap / 1048" | bc)
    swapresult=$(printf "%.0f" $swap_used)
    #swapresult2=$(echo $swapresult MiB)
fi

if [ $swapresult -gt 1024 ]; then
    swapresult2=$(printf "%.2f GiB" $(echo "scale=2; $swapresult / 1024" | bc))
else
    swapresult2=$(echo $swapresult MiB)
fi

#Free Swap
if [ $free_swap -gt 1048576000 ]; then
    free_swap_count=$(echo "scale=2; $free_swap / 1048 / 1048" | bc)
    availableSWAP=$(printf "%.0f" $free_swap_count)
    #availableSWAP2=$(echo $free_swap_count GiB)
else
    free_swap_count=$(echo "scale=2; $free_swap / 1048" | bc)
    availableSWAP=$(printf "%.0f" $free_swap_count)
    #availableSWAP2=$(echo $availableSWAP MiB)
fi
if [ $availableSWAP -gt 1024 ]; then
    availableSWAP2=$(printf "%.2f GiB" $(echo "scale=2; $availableSWAP / 1024" | bc))
else
    availableSWAP2=$(echo $availableSWAP MiB)
fi

#Total Swap
if [ $total_swap -gt 1048576000 ]; then
    total_swap_count=$(echo "scale=2; $total_swap / 1048 / 1048" | bc)
    totalSWAP=$(printf "%.0f" $total_swap_count)
    #totalSWAP2=$(echo $totalSWAP GiB)
else
    total_swap_count=$(echo "scale=2; $total_swap / 1048" | bc)
    totalSWAP=$(printf "%.0f" $total_swap_count)
    #totalSWAP2=$(echo $totalSWAP MiB)
fi
if [ $totalSWAP -gt 1024 ]; then
    totalSWAP2=$(printf "%.2f GiB" $(echo "scale=2; $totalSWAP / 1024" | bc))
else
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
    printf "] $percentSWAP%%" 
    echo ""
    printf "      \033[102m\033[30m F: $availableSWAP2 \033[101m\033[30m U: $swapresult2 \e[0m T: $totalSWAP2"
}

draw_progress_bar_SWAP
wait
echo -n "\n"
echo -n "\n"

echo " Press CTRL+C to clear RAM"

'

LGC

chmod +x LGC.sh
source LGC.sh

clear
echo -e "\033[1;94m"
cat header.txt
echo -e "\e[0m"
echo "                          -PLEASE WAIT, CLEARING-"
while true; do
    echo "";echo -ne "                            \r/ "
    sleep 0.5
    echo -ne "                            \r- "
    sleep 0.5
    echo -ne "                            \r\ "
    sleep 0.5
    echo -ne "                            \r| "
    sleep 0.5
done &
spinner_pid=$!

sleep 2
sudo sync && echo 3 > /proc/sys/vm/drop_caches && kill $spinner_pid
echo "Clearing process completed."

clear
sed -i 's/echo " Press CTRL+C to clear RAM"/echo " Press CTRL+C to EXIT"/g' LGC.sh
sed -i 's/echo "                               -BEFORE CLEARING-"/echo "                              -AFTER CLEARING-"/g' LGC.sh
source LGC.sh

clear
exit
