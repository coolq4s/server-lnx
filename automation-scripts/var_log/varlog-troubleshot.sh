#!/bin/bash
# advanced-log-cleaner.sh

THRESHOLD=75
LOG_DIR="/var/log"
CURRENT_USAGE=$(df "$LOG_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')

cleanup_logs() {
    local urgency=$1  # 1, 2, atau 3
    
    echo "Performing level $urgency cleanup..."
    
    case $urgency in
        1)  # Mild cleanup - safe operations
            find /var/log -name "*.gz" -mtime +30 -delete
            sudo journalctl --vacuum-time=7d
            ;;
        2)  # Moderate cleanup - more aggressive
            find /var/log -name "*.gz" -mtime +7 -delete
            find /var/log -name "*.1" -mtime +3 -delete
            sudo journalctl --vacuum-size=500M
            ;;
        3)  # Aggressive cleanup - emergency
            find /var/log -name "*.gz" -delete
            find /var/log -name "*.1" -delete
            sudo journalctl --vacuum-size=100M
            # Truncate large active logs
            for log in /var/log/syslog /var/log/messages; do
                [ -f "$log" ] && sudo truncate -s 0 "$log"
            done
            ;;
    esac
}

# Logic, sort by usage usage
if [ "$CURRENT_USAGE" -ge 90 ]; then
    cleanup_logs 3
elif [ "$CURRENT_USAGE" -ge 80 ]; then
    cleanup_logs 2
elif [ "$CURRENT_USAGE" -ge 75 ]; then
    cleanup_logs 1
else
    echo "Disk usage: $CURRENT_USAGE% - No cleanup needed"
    exit 0
fi
