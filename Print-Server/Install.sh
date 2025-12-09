#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "Script must run in root. Try with 'sudo'." >&2
  exit 1
fi

echo "Starting installation print server CUPS..."
echo ".Updating system and package"
apt update -y && apt upgrade -y

echo "..Instal CUPS"
apt install cups -y

echo "...Configure CUPS"
CUPS_CONF="/etc/cups/cupsd.conf"
cp "$CUPS_CONF" "$CUPS_CONF.bak"

sed -i 's/Listen localhost:631/Port 631/' "$CUPS_CONF"
sed -i 's/Browsing No/Browsing On/' "$CUPS_CONF"

sed -i '/<Location \/>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow @LOCAL/' "$CUPS_CONF"
sed -i '/<Location \/admin>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow @LOCAL/' "$CUPS_CONF"

echo "....Restart CUPS service"
systemctl restart cups

echo ".....Installing driver printer (Gutenprint for Canon/Epson, HPLIP for HP)"
apt install printer-driver-gutenprint -y
apt install hplip -y

echo "......Installing and actived Avahi daemon..."
apt install avahi-daemon -y
systemctl enable avahi-daemon
systemctl start avahi-daemon

echo ".......Install and configuration Print Server CUPS done"
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "........Access with http://$IP_ADDRESS:631"

rm -rf Install.sh
