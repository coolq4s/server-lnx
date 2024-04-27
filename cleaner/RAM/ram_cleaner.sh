#!/bin/bash
clear
echo "==================="
echo "=== PLEASE WAIT ==="
echo "==================="
wait ;
sleep 3s;
cleanup() {
    rm -rf ram.sh
    rm -rf server-lnx
    rm -rf header.txt
    rm -rf ram_cleaner.sh
    echo " Cleaning up temporary files"
    echo -e " To use again this script,\n you can copy the command from github"
    echo ""
}

trap cleanup EXIT

cat << "EOF" > header.txt
                         ______            ______
                        / ____/___  ____  / / __ \____ ______
                       / /   / __ \/ __ \/ / / / / __ `/ ___/
                      / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
                      \____/\____/\____/_/\___\_\__,_/____/
                                                  RAM CLEANER
EOF
watch -n1 -tc '
echo  "\033[1;94m"
cat header.txt
echo  "\e[0m"
echo ""
echo ""
echo ""
echo ""
echo "                                 -BEFORE CLEARING-"
echo ""
echo ""
#RAM
#Count Used Ram
used=$(free -w | awk "NR==2 {print \$3}")
shared=$(free -w | awk "NR==2 {print \$5}")
buff=$(free -w | awk "NR==2 {print \$6}")
cache=$(free -w | awk "NR==2 {print \$7}")

totalMemUsed=$(($used + $shared + $buff + $cache))


if [ $totalMemUsed -gt 1024000 ]; then
    totaluse=$(echo "scale=2; $totalMemUsed / 1024 / 1024" | bc)
    totalresult=$(echo $totaluse)
    totalresult2=$(echo $totaluse GiB)
else
    totaluse=$(echo "scale=2; $totalMemUsed / 1024" | bc)
    totalresult=$(echo $totaluse)
    totalresult2=$(echo $totaluse MiB)
fi

#Count Installed RAM
totalmem=$(free -w | awk "NR==2 {print \$2}")

if [ $totalmem -gt 1024000 ]; then
    totalmemInstalled=$(echo "scale=2; $totalmem / 1024 / 1024" | bc)
    installedMem=$(echo $totalmemInstalled)
    installedMem2=$(echo $totalmemInstalled GiB)
else
    totalmemInstalled=$(echo "scale=2; $totalmem / 1024" | bc)
    installedMem=$(echo $totalmemInstalled)
    installedMem2=$(echo $totalmemInstalled MiB)
fi

#Count Free RAM
freeRAM=$(free -w | awk "NR==2 {print \$4}")
if [ $freeRAM -gt 1024000 ]; then
    totalfreeRAM=$(echo "scale=2; $freeRAM / 1024 / 1024" | bc)
    availableRAM=$(echo $totalfreeRAM)
    availableRAM2=$(echo $totalfreeRAM GiB)
else
    totalfreeRAM=$(echo "scale=2; $freeRAM / 1024" | bc)
    availableRAM=$(echo $totalfreeRAM)
    availableRAM2=$(echo $totalfreeRAM MiB)
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
    printf "\033[91m%0.s|\e[0m" $(seq 1 $num_bar)
    printf "\033[92m%0.s-\e[0m" $(seq 1 $num_space)
    printf "] %d%%\r" $percent
    echo -n "\n"
    printf "      \033[102m\033[30m F: $availableRAM2 \033[101m\033[30m U: $totalresult2 \e[0m T: $installedMem2"
    echo -n "\n"
}

draw_progress_bar_RAM
echo -n "\n"

#SWAP
used_swap=$(free -w | awk "NR==3 {print \$3}")
free_swap=$(free -w | awk "NR==3 {print \$4}")
total_swap=$(free -w | awk "NR==3 {print \$2}")

if [ $used_swap -gt 1024000 ]; then
    swap_used=$(echo "scale=2; $used_swap / 1024 / 1024" | bc)
    swapresult=$(echo $swap_used)
    swapresult2=$(echo $swap_used GiB)
else
    swap_used=$(echo "scale=2; $used_swap / 1024" | bc)
    swapresult=$(echo $swap_used)
    swapresult2=$(echo $swap_used MiB)
fi

if [ $free_swap -gt 1024000 ]; then
    free_swap_count=$(echo "scale=2; $free_swap / 1024 / 1024" | bc)
    availableSWAP=$(echo $free_swap_count)
    availableSWAP2=$(echo $free_swap_count GiB)
else
    free_swap_count=$(echo "scale=2; $free_swap / 1024" | bc)
    availableSWAP=$(echo $free_swap_count)
    availableSWAP2=$(echo $free_swap_count MiB)
fi


if [ $total_swap -gt 1024000 ]; then
    total_swap_count=$(echo "scale=2; $total_swap / 1024 / 1024" | bc)
    totalSWAP=$(echo $total_swap_count)
    totalSWAP2=$(echo $total_swap_count GiB)
else
    total_swap_count=$(echo "scale=2; $total_swap / 1024" | bc)
    totalSWAP=$(echo $total_swap_count)
    totalSWAP2=$(echo $total_swap_count MiB)
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
    printf "\033[91m%0.s|\e[0m" $(seq 1 $num_barSWAP)
    printf "\033[92m%0.s-\e[0m" $(seq 1 $num_spaceSWAP)
    printf "] %d%%\r" $percentSWAP
    echo -n "\n"
    printf "      \033[102m\033[30m F: $availableSWAP2 \033[101m\033[30m U: $swapresult2 \e[0m T: $totalSWAP2"
}

draw_progress_bar_SWAP
wait
echo -n "\n"
echo -n "\n"
echo -n "\n"
echo " Press CTRL+C to clean the RAM & SWAP"
'
clear
echo -e "\033[1;94m"
cat header.txt
echo -e "\e[0m"
echo ""
echo ""
wait; echo "                             -PLEASE WAIT, CLEARING-"

sudo sync && echo 3 > /proc/sys/vm/drop_caches

clear

watch -n1 -tc '
echo -n "\033[1;94m"
cat header.txt
echo -n "\e[0m"
echo ""
echo ""
echo "                                  -AFTER CLEARING-"
echo ""
echo ""
#RAM
#Count Used Ram
used=$(free -w | awk "NR==2 {print \$3}")
shared=$(free -w | awk "NR==2 {print \$5}")
buff=$(free -w | awk "NR==2 {print \$6}")
cache=$(free -w | awk "NR==2 {print \$7}")

totalMemUsed=$(($used + $shared + $buff + $cache))


if [ $totalMemUsed -gt 1024000 ]; then
    totaluse=$(echo "scale=2; $totalMemUsed / 1024 / 1024" | bc)
    totalresult=$(echo $totaluse)
    totalresult2=$(echo $totaluse GiB)
else
    totaluse=$(echo "scale=2; $totalMemUsed / 1024" | bc)
    totalresult=$(echo $totaluse)
    totalresult2=$(echo $totaluse MiB)
fi

#Count Installed RAM
totalmem=$(free -w | awk "NR==2 {print \$2}")

if [ $totalmem -gt 1024000 ]; then
    totalmemInstalled=$(echo "scale=2; $totalmem / 1024 / 1024" | bc)
    installedMem=$(echo $totalmemInstalled)
    installedMem2=$(echo $totalmemInstalled GiB)
else
    totalmemInstalled=$(echo "scale=2; $totalmem / 1024" | bc)
    installedMem=$(echo $totalmemInstalled)
    installedMem2=$(echo $totalmemInstalled MiB)
fi

#Count Free RAM
freeRAM=$(free -w | awk "NR==2 {print \$4}")
if [ $freeRAM -gt 1024000 ]; then
    totalfreeRAM=$(echo "scale=2; $freeRAM / 1024 / 1024" | bc)
    availableRAM=$(echo $totalfreeRAM)
    availableRAM2=$(echo $totalfreeRAM GiB)
else
    totalfreeRAM=$(echo "scale=2; $freeRAM / 1024" | bc)
    availableRAM=$(echo $totalfreeRAM)
    availableRAM2=$(echo $totalfreeRAM MiB)
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
    printf "\033[91m%0.s|\e[0m" $(seq 1 $num_bar)
    printf "\033[92m%0.s-\e[0m" $(seq 1 $num_space)
    printf "] %d%%\r" $percent
    echo -n "\n"
    printf "      \033[102m\033[30m F: $availableRAM2 \033[101m\033[30m U: $totalresult2 \e[0m T: $installedMem2"
    echo -n "\n"
}

draw_progress_bar_RAM
echo -n "\n"

#SWAP
used_swap=$(free -w | awk "NR==3 {print \$3}")
free_swap=$(free -w | awk "NR==3 {print \$4}")
total_swap=$(free -w | awk "NR==3 {print \$2}")

if [ $used_swap -gt 1024000 ]; then
    swap_used=$(echo "scale=2; $used_swap / 1024 / 1024" | bc)
    swapresult=$(echo $swap_used)
    swapresult2=$(echo $swap_used GiB)
else
    swap_used=$(echo "scale=2; $used_swap / 1024" | bc)
    swapresult=$(echo $swap_used)
    swapresult2=$(echo $swap_used MiB)
fi

if [ $free_swap -gt 1024000 ]; then
    free_swap_count=$(echo "scale=2; $free_swap / 1024 / 1024" | bc)
    availableSWAP=$(echo $free_swap_count)
    availableSWAP2=$(echo $free_swap_count GiB)
else
    free_swap_count=$(echo "scale=2; $free_swap / 1024" | bc)
    availableSWAP=$(echo $free_swap_count)
    availableSWAP2=$(echo $free_swap_count MiB)
fi


if [ $total_swap -gt 1024000 ]; then
    total_swap_count=$(echo "scale=2; $total_swap / 1024 / 1024" | bc)
    totalSWAP=$(echo $total_swap_count)
    totalSWAP2=$(echo $total_swap_count GiB)
else
    total_swap_count=$(echo "scale=2; $total_swap / 1024" | bc)
    totalSWAP=$(echo $total_swap_count)
    totalSWAP2=$(echo $total_swap_count MiB)
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
    printf "\033[91m%0.s|\e[0m" $(seq 1 $num_barSWAP)
    printf "\033[92m%0.s-\e[0m" $(seq 1 $num_spaceSWAP)
    printf "] %d%%\r" $percentSWAP
    echo -n "\n"
    printf "      \033[102m\033[30m F: $availableSWAP2 \033[101m\033[30m U: $swapresult2 \e[0m T: $totalSWAP2"
}

draw_progress_bar_SWAP
echo -n "\n"
echo -n "\n"
echo -n "\n"
echo " Press CTRL+C to exit this tool"
'
clear
exit
