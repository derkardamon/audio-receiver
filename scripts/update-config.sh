#!/bin/bash

# Update script to apply configuration changes

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Updating Raspberry Pi Audio Receiver configuration..."
echo ""

# Update Bluetooth configuration
echo "1. Updating Bluetooth name to 'PiuPiu-Audio'..."
cp -f configs/bluetooth/main.conf /etc/bluetooth/main.conf

# Update auto-pair script
echo "2. Updating bluetooth-autopair script..."
cp -f scripts/bluetooth-autopair /usr/local/bin/bluetooth-autopair
chmod +x /usr/local/bin/bluetooth-autopair

# Restart services
echo "3. Restarting Bluetooth services..."
systemctl restart bluetooth
sleep 2
systemctl restart bluetooth-autopair

echo ""
echo "Update complete!"
echo ""
echo "Checking status..."
systemctl status bluetooth-autopair --no-pager -l

echo ""
echo "Your device should now appear as 'PiuPiu-Audio' on your iPhone/Android"
