#!/bin/bash

# Test Bluetooth Pairing Setup
# This script checks all aspects of the pairing configuration

set -e

echo "=========================================="
echo "Bluetooth Pairing Configuration Test"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check function
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1"
        return 1
    fi
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 1. Check if Bluetooth service is running
echo "1. Checking Bluetooth service..."
systemctl is-active --quiet bluetooth
check "Bluetooth service is running"
echo ""

# 2. Check if autopair service is running
echo "2. Checking bluetooth-autopair service..."
systemctl is-active --quiet bluetooth-autopair
check "Autopair service is running"
echo ""

# 3. Check Python dependencies
echo "3. Checking Python dependencies..."
python3 -c "import dbus; import gi.repository.GLib" 2>/dev/null
check "Python dependencies installed (dbus, gi)"
echo ""

# 4. Check if scripts exist and are executable
echo "4. Checking script files..."
[ -x /usr/local/bin/bluetooth-autopair ]
check "bluetooth-autopair script exists and is executable"
[ -f /usr/local/bin/bluetooth-autopair.py ]
check "bluetooth-autopair.py exists"
echo ""

# 5. Check Bluetooth controller status
echo "5. Checking Bluetooth controller..."
POWERED=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
DISCOVERABLE=$(bluetoothctl show | grep "Discoverable:" | awk '{print $2}')
PAIRABLE=$(bluetoothctl show | grep "Pairable:" | awk '{print $2}')

if [ "$POWERED" = "yes" ]; then
    check "Bluetooth is powered on"
else
    warn "Bluetooth is NOT powered on - run: bluetoothctl power on"
fi

if [ "$DISCOVERABLE" = "yes" ]; then
    check "Bluetooth is discoverable"
else
    warn "Bluetooth is NOT discoverable - run: bluetoothctl discoverable on"
fi

if [ "$PAIRABLE" = "yes" ]; then
    check "Bluetooth is pairable"
else
    warn "Bluetooth is NOT pairable - run: bluetoothctl pairable on"
fi
echo ""

# 6. Check recent autopair logs
echo "6. Checking recent autopair service logs..."
if journalctl -u bluetooth-autopair --since "5 minutes ago" | grep -q "registered successfully"; then
    check "Agent registered successfully"
else
    warn "No recent successful agent registration found"
fi
echo ""

# 7. Show recent errors
echo "7. Recent errors (if any)..."
ERRORS=$(journalctl -u bluetooth-autopair --since "5 minutes ago" -p err --no-pager -n 5)
if [ -z "$ERRORS" ]; then
    check "No recent errors"
else
    echo -e "${RED}Recent errors:${NC}"
    echo "$ERRORS"
fi
echo ""

# 8. List paired devices
echo "8. Currently paired devices..."
PAIRED=$(bluetoothctl devices Paired 2>/dev/null)
if [ -z "$PAIRED" ]; then
    echo "   No devices paired yet"
else
    echo "$PAIRED"
fi
echo ""

echo "=========================================="
echo "Configuration Files"
echo "=========================================="
echo ""

# Show relevant config
echo "Bluetooth main.conf settings:"
grep -E "^(Discoverable|AlwaysPairable|DiscoverableTimeout|AutoEnable)" /etc/bluetooth/main.conf 2>/dev/null || echo "   No custom settings found"
echo ""

echo "=========================================="
echo "Next Steps"
echo "=========================================="
echo ""
echo "To test pairing:"
echo "1. Make sure device is discoverable:"
echo "   bluetoothctl discoverable on"
echo ""
echo "2. Watch logs in real-time:"
echo "   sudo journalctl -u bluetooth-autopair -f"
echo ""
echo "3. Try pairing from your phone/device"
echo ""
echo "4. If pairing fails, run for detailed output:"
echo "   sudo systemctl stop bluetooth-autopair"
echo "   sudo python3 /usr/local/bin/bluetooth-autopair.py"
echo "   (Then try pairing and watch the output)"
echo ""
