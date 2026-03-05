#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "Error: Please run as root"
  exit 1
fi

echo "--- Rebuilding Tailscale Monitoring (Clean Version) ---"

SCRIPT_DIR="/root/script/tailscale"
SCRIPT_PATH="$SCRIPT_DIR/tailscale-checker.sh"

mkdir -p "$SCRIPT_DIR"
chmod 700 "$SCRIPT_DIR"

# Menggunakan 'EOF' dengan kutip tunggal sangat penting untuk mencegah shell expansion
cat << 'EOF' > "$SCRIPT_PATH"
#!/bin/bash

# Check command
if ! command -v tailscale &> /dev/null; then
    exit 1
fi

# Get Data
STATUS_DATA=$(/usr/bin/tailscale status | grep "^[0-9]")
MY_IP=$(echo "$STATUS_DATA" | head -n 1 | awk '{print $1}')
ONLINE_TARGETS=$(echo "$STATUS_DATA" | tail -n +2 | grep "^100\." | grep -v "offline" | grep -v "$MY_IP" | awk '{print $1}')

echo "[$(date)] --- New Cycle ---"

if [ -n "$ONLINE_TARGETS" ]; then
    for IP in $ONLINE_TARGETS; do
        [[ ! "$IP" =~ ^100\. ]] && continue
        
        echo "   > Testing $IP (30x)..."
        RECEIVED=$(/usr/bin/ping -c 30 -i 1 -W 1 "$IP" | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
        
        [[ -z "$RECEIVED" ]] && RECEIVED=0
        LOSS=$((30 - RECEIVED))
        echo "   > Result: $RECEIVED ok, $LOSS fail."

        if [ "$LOSS" -ge 25 ]; then
            echo "   > ALERT: Restarting Tailscale..."
            /usr/bin/tailscale down && /usr/bin/sleep 2 && /usr/bin/tailscale up
            exit 0
        fi
    done
else
    echo "   > Status: No active peers to test."
fi

echo "[$(date)] --- Cycle Finished ---"
EOF

# Fix format & permission
sed -i 's/\r$//' "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# Systemd Service
cat << 'EOF' > /etc/systemd/system/tailscale-checker.service
[Unit]
Description=Tailscale Connection Checker
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash /root/script/tailscale/tailscale-checker.sh
User=root
WorkingDirectory=/root/script/tailscale/
EOF

# Systemd Timer
cat << 'EOF' > /etc/systemd/system/tailscale-checker.timer
[Unit]
Description=Run Tailscale Checker with 1 min rest

[Timer]
OnBootSec=1min
OnUnitInactiveSec=1min
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now tailscale-checker.timer
systemctl restart tailscale-checker.timer

echo "------------------------------------------------"
echo "✅ SETUP COMPLETED"
echo "------------------------------------------------"
echo "To monitor logs, use:"
echo "journalctl -u tailscale-checker.service -f"
echo "------------------------------------------------"
