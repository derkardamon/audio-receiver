#!/bin/bash

# Fix Bluetooth Pairing Issues
# This script addresses common pairing problems

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "Bluetooth Pairing Fix Script"
echo -e "==========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# 1. Stop services
echo -e "${YELLOW}[1/9]${NC} Stopping services..."
systemctl stop bluetooth-autopair 2>/dev/null || true
systemctl stop bluetooth
sleep 2
echo -e "${GREEN}✓${NC} Services stopped"
echo ""

# 2. Ensure Python dependencies
echo -e "${YELLOW}[2/9]${NC} Checking Python dependencies..."
if ! python3 -c "import dbus" 2>/dev/null; then
    echo "Installing python3-dbus..."
    apt-get update -qq
    apt-get install -y python3-dbus
fi
if ! python3 -c "import gi.repository.GLib" 2>/dev/null; then
    echo "Installing python3-gi..."
    apt-get install -y python3-gi
fi
echo -e "${GREEN}✓${NC} Python dependencies OK"
echo ""

# 3. Update Bluetooth configuration
echo -e "${YELLOW}[3/9]${NC} Updating Bluetooth configuration..."
if ! grep -q "^DiscoverableTimeout = 0" /etc/bluetooth/main.conf; then
    sed -i '/^\[General\]/a DiscoverableTimeout = 0' /etc/bluetooth/main.conf
fi
if ! grep -q "^AlwaysPairable = yes" /etc/bluetooth/main.conf; then
    sed -i '/^\[General\]/a AlwaysPairable = yes' /etc/bluetooth/main.conf
fi
if ! grep -q "^Discoverable = true" /etc/bluetooth/main.conf; then
    sed -i '/^\[General\]/a Discoverable = true' /etc/bluetooth/main.conf
fi
echo -e "${GREEN}✓${NC} Configuration updated"
echo ""

# 4. Start Bluetooth service
echo -e "${YELLOW}[4/9]${NC} Starting Bluetooth service..."
systemctl start bluetooth
sleep 3
systemctl is-active --quiet bluetooth && echo -e "${GREEN}✓${NC} Bluetooth service running" || echo -e "${RED}✗${NC} Bluetooth service failed"
echo ""

# 5. Power on and configure Bluetooth
echo -e "${YELLOW}[5/9]${NC} Configuring Bluetooth controller..."
bluetoothctl power on
sleep 1
bluetoothctl discoverable on
bluetoothctl pairable on
echo -e "${GREEN}✓${NC} Bluetooth configured (powered, discoverable, pairable)"
echo ""

# 6. Start autopair service
echo -e "${YELLOW}[6/9]${NC} Starting bluetooth-autopair service..."
systemctl start bluetooth-autopair
sleep 3
systemctl is-active --quiet bluetooth-autopair && echo -e "${GREEN}✓${NC} Autopair service running" || echo -e "${RED}✗${NC} Autopair service failed"
echo ""

# 7. Check agent registration
echo -e "${YELLOW}[7/9]${NC} Checking agent registration..."
sleep 2
if journalctl -u bluetooth-autopair --since "30 seconds ago" | grep -q "registered successfully"; then
    echo -e "${GREEN}✓${NC} Agent registered successfully"
else
    echo -e "${YELLOW}⚠${NC} Agent registration not confirmed in logs"
fi
echo ""

# 8. Show Bluetooth info
echo -e "${YELLOW}[8/9]${NC} Bluetooth controller status:"
bluetoothctl show | grep -E "Name:|Powered:|Discoverable:|Pairable:" | sed 's/^/   /'
echo ""

# 9. Check for errors
echo -e "${YELLOW}[9/9]${NC} Checking for recent errors..."
ERRORS=$(journalctl -u bluetooth-autopair --since "1 minute ago" -p err --no-pager)
if [ -z "$ERRORS" ]; then
    echo -e "${GREEN}✓${NC} No errors detected"
else
    echo -e "${RED}Recent errors found:${NC}"
    echo "$ERRORS"
fi
echo ""

echo -e "${BLUE}=========================================="
echo "Fix Complete"
echo -e "==========================================${NC}"
echo ""
echo -e "${GREEN}Your device should now be ready for pairing!${NC}"
echo ""
echo "To test:"
echo "1. On your phone/device, search for Bluetooth devices"
echo "2. Look for this device (name shown above)"
echo "3. Attempt to pair"
echo ""
echo "To watch pairing attempts in real-time:"
echo "   sudo journalctl -u bluetooth-autopair -f"
echo ""
echo "If pairing still fails, run:"
echo "   bash scripts/test-pairing.sh"
echo ""
