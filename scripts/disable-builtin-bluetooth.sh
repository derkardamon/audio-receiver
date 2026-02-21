#!/bin/bash
# Script to disable built-in Bluetooth and make USB adapter hci0

set -e

echo "Disabling built-in Bluetooth adapter..."

# Stop Bluetooth services
sudo systemctl stop bluetooth
sudo systemctl stop hciuart || true

# Disable hciuart service (built-in Bluetooth)
sudo systemctl disable hciuart || true

# Add dtoverlay to disable built-in Bluetooth in /boot/firmware/config.txt
CONFIG_FILE="/boot/firmware/config.txt"
if [ -f "$CONFIG_FILE" ]; then
    if ! grep -q "^dtoverlay=disable-bt" "$CONFIG_FILE"; then
        echo "dtoverlay=disable-bt" | sudo tee -a "$CONFIG_FILE"
        echo "Added dtoverlay=disable-bt to $CONFIG_FILE"
    else
        echo "dtoverlay=disable-bt already present in $CONFIG_FILE"
    fi
else
    echo "Warning: $CONFIG_FILE not found"
fi

echo ""
echo "Built-in Bluetooth has been disabled."
echo "After reboot, the USB adapter will become hci0."
echo ""
echo "Please reboot now: sudo reboot"
