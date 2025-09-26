#!/bin/bash

cleanup() {
    clear
    cd /coolq4s-scripts
    rm -rf "header.txt" 2>/dev/null
    rm -rf server-lnx 2>/dev/null
    echo ""
    echo " Cleaning up temporary files"
    echo " To try again this script,"
    echo " you can copy the command from github"
    echo ""
    echo " var/log is automatically cleaned up"
}

trap cleanup EXIT

clear

echo -e "\e[92m"
cat << "EOF" > header.txt
    ______            ______
   / ____/___  ____  / / __ \____ ______
  / /   / __ \/ __ \/ / / / / __ `/ ___/
 / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
 \____/\____/\____/_/\___\_\__,_/____/
                            VARLOG FIXER
EOF

if [ ! -f "header.txt" ]; then
    echo "Error: Failed to create header file!"
    exit 1
fi

# Load Header
cat "header.txt"
sleep 1s

echo ""
echo ""

pause() {
  read -r -p "Press [Enter] to exit"
}

echo "Creating service varlog-troubleshot..."

# Create Service File
sudo tee /etc/systemd/system/varlog-troubleshot.service > /dev/null <<EOF
[Unit]
Description=Var/Log Cleanup Service

[Service]
Type=oneshot
User=root
ExecStart=/script/varlog-troubleshot.sh
StandardOutput=journal
StandardError=journal
EOF

# Create Timer File
sudo tee /etc/systemd/system/varlog-troubleshot.timer > /dev/null <<EOF
[Unit]
Description=Hourly var/log cleanup
Requires=varlog-troubleshot.service

[Timer]
OnCalendar=hourly
Persistent=true
RandomizedDelaySec=300

[Install]
WantedBy=timers.target
EOF

echo "✓ File service and timer created"

# Set permissions
sudo chmod 644 /etc/systemd/system/varlog-troubleshot.service
sudo chmod 644 /etc/systemd/system/varlog-troubleshot.timer
sudo chmod +x /script/varlog-troubleshot.sh
echo "✓ Permissions set"

# Reload systemd
sudo systemctl daemon-reload
echo "✓ Systemd reloaded"

# Enable and start TIMER
sudo systemctl enable varlog-troubleshot.timer
echo "✓ Timer enabled"

sudo systemctl start varlog-troubleshot.timer
echo "✓ Timer started"

# Verify installation
echo ""
echo "=== Verification ==="
echo "Timer status:"
sudo systemctl status varlog-troubleshot.timer --no-pager

echo ""
echo "Next run time:"
sudo systemctl list-timers | grep varlog-troubleshot || echo "Timer not found in list"

echo ""
echo "Service varlog-troubleshot successfully installed!"
echo ""
echo "Commands to manage:"
echo "  sudo systemctl status varlog-troubleshot.timer    # Check timer"
echo "  sudo systemctl status varlog-troubleshot.service  # Check service"
echo "  sudo journalctl -u varlog-troubleshot.service -f  # View logs"
echo "  sudo systemctl stop varlog-troubleshot.timer      # Stop timer"
echo "  sudo systemctl start varlog-troubleshot.timer     # Start timer"
echo ""
echo "Manual test: sudo systemctl start varlog-troubleshot.service"

rm -rf header.txt

pause
exit
