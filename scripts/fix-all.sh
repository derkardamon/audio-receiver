#!/bin/bash
set -e

echo "========================================="
echo "Fixing Audio Configuration"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Fix sound card ordering
echo "1. Fixing sound card order (HiFiBerry as Card 0)..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$PROJECT_DIR/configs/alsa/alsa-base.conf" ]; then
    cp -f "$PROJECT_DIR/configs/alsa/alsa-base.conf" /etc/modprobe.d/alsa-base.conf
    echo "   ✓ ALSA configuration installed"
else
    echo "   ✗ Error: alsa-base.conf not found"
    exit 1
fi

# Check if PipeWire is installed
echo ""
echo "2. Checking PipeWire installation..."
if ! command -v pipewire &> /dev/null || ! command -v wireplumber &> /dev/null; then
    echo "   ! PipeWire not found. Installing..."
    apt-get update
    apt-get install -y pipewire pipewire-audio wireplumber pipewire-pulse libspa-0.2-bluetooth
    echo "   ✓ PipeWire installed"
else
    echo "   ✓ PipeWire is installed"
fi

# Install PipeWire configurations
echo ""
echo "3. Installing PipeWire configurations..."
mkdir -p /etc/pipewire
mkdir -p /etc/wireplumber/bluetooth.lua.d
mkdir -p /etc/wireplumber/main.lua.d

if [ -f "$PROJECT_DIR/configs/pipewire/pipewire.conf" ]; then
    cp -f "$PROJECT_DIR/configs/pipewire/pipewire.conf" /etc/pipewire/pipewire.conf
    echo "   ✓ pipewire.conf installed"
fi

if [ -f "$PROJECT_DIR/configs/pipewire/pipewire-pulse.conf" ]; then
    cp -f "$PROJECT_DIR/configs/pipewire/pipewire-pulse.conf" /etc/pipewire/pipewire-pulse.conf
    echo "   ✓ pipewire-pulse.conf installed"
fi

if [ -f "$PROJECT_DIR/configs/wireplumber/bluetooth.lua.d/50-bluez-config.lua" ]; then
    cp -f "$PROJECT_DIR/configs/wireplumber/bluetooth.lua.d/50-bluez-config.lua" /etc/wireplumber/bluetooth.lua.d/50-bluez-config.lua
    echo "   ✓ WirePlumber bluetooth config installed"
fi

if [ -f "$PROJECT_DIR/configs/wireplumber/main.lua.d/50-bluez-config.lua" ]; then
    cp -f "$PROJECT_DIR/configs/wireplumber/main.lua.d/50-bluez-config.lua" /etc/wireplumber/main.lua.d/50-bluez-config.lua
    echo "   ✓ WirePlumber main config installed"
fi

if [ -f "$PROJECT_DIR/configs/wireplumber/main.lua.d/51-alsa-hifiberry.lua" ]; then
    cp -f "$PROJECT_DIR/configs/wireplumber/main.lua.d/51-alsa-hifiberry.lua" /etc/wireplumber/main.lua.d/51-alsa-hifiberry.lua
    echo "   ✓ WirePlumber HiFiBerry config installed"
fi

# Enable PipeWire services
echo ""
echo "4. Enabling PipeWire services..."
systemctl --global disable pulseaudio.service pulseaudio.socket 2>/dev/null || true
systemctl --global enable pipewire pipewire-pulse wireplumber
echo "   ✓ PipeWire services enabled"

# Enable lingering for the sudo user
if [ -n "$SUDO_USER" ]; then
    echo ""
    echo "5. Enabling user lingering for $SUDO_USER..."
    loginctl enable-linger $SUDO_USER
    echo "   ✓ User lingering enabled"
fi

echo ""
echo "========================================="
echo "Configuration complete!"
echo "========================================="
echo ""
echo "Changes made:"
echo "  • HiFiBerry will be Card 0 (HDMI moved to Card 1 & 2)"
echo "  • PipeWire configured for HiFiBerry output"
echo "  • PipeWire services enabled"
echo ""
echo "IMPORTANT: You must reboot for changes to take effect."
echo ""
read -p "Reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    reboot
else
    echo "Please reboot manually: sudo reboot"
fi
