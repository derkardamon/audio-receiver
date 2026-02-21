#!/bin/bash

# Fix sound card ordering - make HiFiBerry Card 0 instead of Card 2
# This ensures Bluetooth audio defaults to the HiFiBerry DAC

set -e

echo "Fixing sound card order..."

# Create ALSA modprobe configuration
sudo mkdir -p /etc/modprobe.d
sudo cp "$(dirname "$0")/../configs/alsa/alsa-base.conf" /etc/modprobe.d/alsa-base.conf

echo "Configuration installed to /etc/modprobe.d/alsa-base.conf"
echo ""
echo "Reboot required for changes to take effect."
echo ""
echo "After reboot, run 'aplay -l' to verify HiFiBerry is Card 0"
echo ""
read -p "Reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo reboot
fi
