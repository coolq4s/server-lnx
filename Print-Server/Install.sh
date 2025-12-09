#!/bin/bash

# --- Color Variables ---
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${YELLOW}Script must run in root. Try with 'sudo'.${NC}" >&2
  exit 1
fi

echo -e "${YELLOW}Starting installation print server CUPS${NC}"
echo -e "${YELLOW}Updating system and package${NC}"
apt update -y && apt upgrade -y

echo -e "${YELLOW}Instal CUPS${NC}"
apt install cups -y

echo -e "${YELLOW}Configure CUPS${NC}"
CUPS_CONF="/etc/cups/cupsd.conf"
cp "$CUPS_CONF" "$CUPS_CONF.bak"

sed -i 's/Listen localhost:631/Port 631/' "$CUPS_CONF"
sed -i 's/Browsing No/Browsing On/' "$CUPS_CONF"

sed -i '/<Location \/>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow @LOCAL/' "$CUPS_CONF"
sed -i '/<Location \/admin>/,/<\/Location>/ s/Order allow,deny/Order allow,deny\n  Allow @LOCAL/' "$CUPS_CONF"

echo -e "${YELLOW}Restart CUPS service${NC}"
systemctl restart cups

echo -e "${YELLOW}Installing driver printer (Gutenprint for Canon/Epson, HPLIP for HP)${NC}"
apt install printer-driver-gutenprint -y
apt install hplip -y

echo -e "${YELLOW}Installing and actived Avahi daemon...${NC}"
apt install avahi-daemon -y
systemctl enable avahi-daemon
systemctl start avahi-daemon

echo -e "${GREEN}Install and configuration Print Server CUPS done${NC}"
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}Access with http://$IP_ADDRESS:631${NC}"

rm -rf Install.sh
