#!/bin/bash

IP_TARGET="8.8.8.8"
MAX_FAILURES=30 
PING_CMD="/bin/ping"
REBOOT_CMD="/sbin/reboot"
FAIL_COUNT=0 

# Loop
while true; do
    $PING_CMD -c 1 -W 1 $IP_TARGET -q 2>&1 > /dev/null

    if [ $? -eq 0 ]; then
        FAIL_COUNT=0
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        if [ $FAIL_COUNT -ge $MAX_FAILURES ]; then
            echo "$(date) - ERROR: Ping ke $IP_TARGET gagal $MAX_FAILURES kali berturut-turut. MEREBOOT SISTEM..." | /usr/bin/logger -t ping_watchdog
            FAIL_COUNT=0
            
            $REBOOT_CMD
        fi
    fi
    sleep 1 
done
