#!/bin/bash
cleanup() {
    clear
    # Kembali ke direktori awal script dijalankan
    cd /coolq4s-scripts
    rm -rf "header.txt"
    rm -rf server-lnx
    echo ""
    echo " Cleaning up temporary files"
    echo " To try again this script,"
    echo " you can copy the command from github"
    echo ""
    echo ""
    echo " Watchdog INSTALLED"
}

trap cleanup EXIT

clear

echo -e "\033[1;94m"
cat << "EOF" > header.txt
    ______            ______
   / ____/___  ____  / / __ \____ ______
  / /   / __ \/ __ \/ / / / / __ `/ ___/
 / /___/ /_/ / /_/ / / /_/ / /_/ (__  )
 \____/\____/\____/_/\___\_\__,_/____/
                      WATCHDOG INSTALLER
EOF
if [ ! -f "header.txt" ]; then
    echo "Error: Failed to create header file!"
    exit 1
fi

#Load Header
cat "header.txt"
sleep 1s

echo ""
echo ""

pause() {
  read -r -p "Press [Enter] to exit"
}

echo "Creating service ping-watchdog..."

sudo tee /etc/systemd/system/ping-watchdog.service > /dev/null <<EOF
[Unit]
Description=Ping Reboot Watchdog Service

[Service]
User=root
ExecStart=/script/Ping-watchdog.sh
Type=simple

[Install]
WantedBy=multi-user.target
EOF
echo "✓ File service created"
sudo chmod 644 /etc/systemd/system/ping-watchdog.service
sudo chmod +x /script/Ping-watchdog.sh
echo "✓ Permissions set"

sudo systemctl daemon-reload
echo "✓ Systemd reloaded"

sudo systemctl enable ping-watchdog.service
echo "✓ Service enabled"

sudo systemctl start ping-watchdog.service
echo "✓ Service started"

echo "Status service:"
sudo systemctl status ping-watchdog.service --no-pager

echo "Service ping-watchdog successfully created and activated!"
echo "Command to check status service:"
echo "  sudo systemctl status ping-watchdog.service"
echo "  sudo systemctl stop ping-watchdog.service"
echo "  sudo systemctl restart ping-watchdog.service"
echo "  sudo journalctl -u ping-watchdog.service -f"

echo -e "\e[92m DONE"
echo -e "\e[0m"
pause
exit
