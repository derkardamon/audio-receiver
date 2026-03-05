#!/bin/bash

# Fix Bluetooth Device Name and Pairing Issues
# Ensures device shows as "PiuPiu-Audio" and accepts connections

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "Bluetooth Name & Connection Fix"
echo -e "==========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# 1. Set system hostname
echo -e "${YELLOW}[1/10]${NC} Setting system hostname to 'piupiu'..."
hostnamectl set-hostname piupiu
hostnamectl set-hostname "PiuPiu-Audio" --pretty
echo -e "${GREEN}✓${NC} Hostname configured"
echo ""

# 2. Update /etc/hosts
echo -e "${YELLOW}[2/10]${NC} Updating /etc/hosts..."
sed -i 's/127.0.1.1.*/127.0.1.1\tpiupiu/' /etc/hosts
if ! grep -q "127.0.1.1.*piupiu" /etc/hosts; then
    echo "127.0.1.1	piupiu" >> /etc/hosts
fi
echo -e "${GREEN}✓${NC} /etc/hosts updated"
echo ""

# 3. Stop services
echo -e "${YELLOW}[3/10]${NC} Stopping services..."
systemctl stop bluetooth-autopair 2>/dev/null || true
systemctl stop bluetooth
sleep 2
echo -e "${GREEN}✓${NC} Services stopped"
echo ""

# 4. Clear Bluetooth cache
echo -e "${YELLOW}[4/10]${NC} Clearing Bluetooth cache..."
rm -rf /var/lib/bluetooth/*/cache
echo -e "${GREEN}✓${NC} Cache cleared"
echo ""

# 5. Update Bluetooth main.conf
echo -e "${YELLOW}[5/10]${NC} Ensuring Bluetooth configuration..."
CONF="/etc/bluetooth/main.conf"

# Ensure our config is in place
cp configs/bluetooth/main.conf "$CONF" 2>/dev/null || \
cp /tmp/cc-agent/*/project/configs/bluetooth/main.conf "$CONF"

echo -e "${GREEN}✓${NC} Bluetooth config updated"
echo ""

# 6. Remove any conflicting machine-info
echo -e "${YELLOW}[6/10]${NC} Removing conflicting system names..."
if [ -f /etc/machine-info ]; then
    # Keep PRETTY_HOSTNAME but ensure it doesn't conflict
    echo 'PRETTY_HOSTNAME=PiuPiu-Audio' > /etc/machine-info
fi
echo -e "${GREEN}✓${NC} System names cleaned"
echo ""

# 7. Start Bluetooth
echo -e "${YELLOW}[7/10]${NC} Starting Bluetooth service..."
systemctl start bluetooth
sleep 3
if systemctl is-active --quiet bluetooth; then
    echo -e "${GREEN}✓${NC} Bluetooth service running"
else
    echo -e "${RED}✗${NC} Bluetooth service failed to start"
    journalctl -u bluetooth --no-pager -n 20
    exit 1
fi
echo ""

# 8. Configure Bluetooth controller
echo -e "${YELLOW}[8/10]${NC} Configuring Bluetooth controller..."
bluetoothctl power off
sleep 1
bluetoothctl power on
sleep 1
bluetoothctl discoverable on
bluetoothctl pairable on
bluetoothctl agent NoInputNoOutput
bluetoothctl default-agent
echo -e "${GREEN}✓${NC} Controller configured"
echo ""

# 9. Start autopair service
echo -e "${YELLOW}[9/10]${NC} Starting bluetooth-autopair service..."
systemctl start bluetooth-autopair
sleep 3
if systemctl is-active --quiet bluetooth-autopair; then
    echo -e "${GREEN}✓${NC} Autopair service running"
else
    echo -e "${YELLOW}⚠${NC} Autopair service not running (checking logs...)"
    journalctl -u bluetooth-autopair --no-pager -n 10
fi
echo ""

# 10. Display status
echo -e "${YELLOW}[10/10]${NC} Bluetooth status:"
echo ""
bluetoothctl show | grep -E "Name:|Powered:|Discoverable:|Pairable:" | sed 's/^/   /'
echo ""

echo -e "${BLUE}=========================================="
echo "Fix Complete!"
echo -e "==========================================${NC}"
echo ""
echo -e "${GREEN}Device name: PiuPiu-Audio${NC}"
echo ""
echo "Please try pairing now from your device."
echo ""
echo "To monitor pairing attempts:"
echo "   sudo journalctl -u bluetooth-autopair -f"
echo ""
echo "If you see 'ignore device' errors, check:"
echo "   sudo journalctl -u bluetooth -n 50"
echo ""
