#!/bin/bash
set -e

echo "========================================="
echo "Raspberry Pi Audio Receiver Uninstallation"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Stop services
echo "Stopping services..."
systemctl stop bluetooth-autopair 2>/dev/null || true
systemctl disable bluetooth-autopair 2>/dev/null || true

# Remove configuration files
echo "Removing configuration files..."
rm -f /usr/local/bin/bluetooth-autopair
rm -f /etc/systemd/system/bluetooth-autopair.service

# Restore default Bluetooth configuration
echo "Restoring default Bluetooth configuration..."
apt-get install --reinstall -y bluez

# Remove HiFiBerry overlay and re-enable internal audio
echo "Removing HiFiBerry configuration..."
sed -i '/^dtoverlay=hifiberry-dacplusadcpro/d' /boot/config.txt
sed -i '/^dtoverlay=disable-bt/d' /boot/config.txt

# Re-enable internal audio
if ! grep -q "dtparam=audio=on" /boot/config.txt; then
    echo "dtparam=audio=on" >> /boot/config.txt
fi

# Remove blacklist
rm -f /etc/modprobe.d/raspi-blacklist.conf

# Reload systemd
systemctl daemon-reload

echo ""
echo "========================================="
echo "Uninstallation complete!"
echo "========================================="
echo ""
echo "Please reboot your Raspberry Pi for changes to take effect."
echo ""
echo "To reboot now, run: sudo reboot"
