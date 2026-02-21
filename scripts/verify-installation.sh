#!/bin/bash

# Installation verification script

echo "========================================="
echo "Verifying Raspberry Pi Audio Receiver Installation"
echo "========================================="
echo ""

ERRORS=0

# Check for required files
echo "Checking configuration files..."

if [ -f "/etc/bluetooth/main.conf" ]; then
    echo "✓ Bluetooth configuration found"
else
    echo "✗ Bluetooth configuration missing"
    ((ERRORS++))
fi

if [ -f "/etc/pipewire/pipewire.conf" ]; then
    echo "✓ PipeWire configuration found"
else
    echo "✗ PipeWire configuration missing"
    ((ERRORS++))
fi

if [ -f "/etc/wireplumber/bluetooth.lua.d/50-bluez-config.lua" ]; then
    echo "✓ WirePlumber Bluetooth configuration found"
else
    echo "✗ WirePlumber Bluetooth configuration missing"
    ((ERRORS++))
fi

if [ -f "/usr/local/bin/bluetooth-autopair" ]; then
    echo "✓ Auto-pair script found"
else
    echo "✗ Auto-pair script missing"
    ((ERRORS++))
fi

echo ""
echo "Checking boot configuration..."

if grep -q "dtoverlay=hifiberry-dacplusadcpro" /boot/config.txt; then
    echo "✓ HiFiBerry overlay configured"
else
    echo "✗ HiFiBerry overlay not configured"
    ((ERRORS++))
fi

if grep -q "dtoverlay=disable-bt" /boot/config.txt; then
    echo "✓ Internal Bluetooth disabled"
else
    echo "✗ Internal Bluetooth not disabled"
    ((ERRORS++))
fi

echo ""
echo "Checking services..."

if systemctl is-enabled --quiet bluetooth; then
    echo "✓ Bluetooth service enabled"
else
    echo "✗ Bluetooth service not enabled"
    ((ERRORS++))
fi

if systemctl is-enabled --quiet bluetooth-autopair; then
    echo "✓ Auto-pair service enabled"
else
    echo "✗ Auto-pair service not enabled"
    ((ERRORS++))
fi

echo ""
echo "Checking required packages..."

PACKAGES=("bluez" "pipewire" "wireplumber")
for pkg in "${PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $pkg"; then
        echo "✓ $pkg installed"
    else
        echo "✗ $pkg not installed"
        ((ERRORS++))
    fi
done

echo ""
echo "========================================="
if [ $ERRORS -eq 0 ]; then
    echo "✓ Installation verified successfully!"
    echo "Please reboot to complete setup."
else
    echo "✗ Found $ERRORS error(s)"
    echo "Please run: sudo ./install.sh"
fi
echo "========================================="

exit $ERRORS
