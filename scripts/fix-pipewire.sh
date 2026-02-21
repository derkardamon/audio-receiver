#!/bin/bash
# Fix PipeWire and WirePlumber configuration issues

set -e

echo "=== PipeWire & WirePlumber Fix Script ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

echo "Step 1: Stopping PipeWire services..."
systemctl --user -M pi@ stop pipewire pipewire-pulse wireplumber 2>/dev/null || true
killall -9 pipewire pipewire-pulse wireplumber 2>/dev/null || true
sleep 2

echo "Step 2: Backing up old configurations..."
BACKUP_DIR="/home/pi/.config/pipewire-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -d "/home/pi/.config/pipewire" ]; then
    cp -r /home/pi/.config/pipewire/* "$BACKUP_DIR/" 2>/dev/null || true
    echo "Backup saved to: $BACKUP_DIR"
fi

if [ -d "/home/pi/.config/wireplumber" ]; then
    cp -r /home/pi/.config/wireplumber/* "$BACKUP_DIR/" 2>/dev/null || true
fi

echo "Step 3: Cleaning old configurations..."
rm -rf /home/pi/.config/pipewire
rm -rf /home/pi/.config/wireplumber
rm -rf /home/pi/.local/state/pipewire
rm -rf /home/pi/.local/state/wireplumber

echo "Step 4: Creating new configuration directories..."
mkdir -p /home/pi/.config/pipewire/pipewire.conf.d
mkdir -p /home/pi/.config/pipewire/pipewire-pulse.conf.d
mkdir -p /home/pi/.config/wireplumber/main.lua.d
mkdir -p /home/pi/.config/wireplumber/bluetooth.lua.d

echo "Step 5: Installing updated configurations..."

# Copy PipeWire configs
if [ -f "./configs/pipewire/pipewire.conf" ]; then
    cp ./configs/pipewire/pipewire.conf /home/pi/.config/pipewire/
fi

if [ -f "./configs/pipewire/pipewire-pulse.conf" ]; then
    cp ./configs/pipewire/pipewire-pulse.conf /home/pi/.config/pipewire/
fi

# Copy WirePlumber configs (both old and new locations)
if [ -f "./configs/wireplumber/bluetooth.lua.d/50-bluez-config.lua" ]; then
    cp ./configs/wireplumber/bluetooth.lua.d/50-bluez-config.lua /home/pi/.config/wireplumber/bluetooth.lua.d/
fi

if [ -f "./configs/wireplumber/main.lua.d/50-bluez-config.lua" ]; then
    cp ./configs/wireplumber/main.lua.d/50-bluez-config.lua /home/pi/.config/wireplumber/main.lua.d/
fi

if [ -f "./configs/wireplumber/main.lua.d/51-alsa-hifiberry.lua" ]; then
    cp ./configs/wireplumber/main.lua.d/51-alsa-hifiberry.lua /home/pi/.config/wireplumber/main.lua.d/
fi

echo "Step 6: Setting correct permissions..."
chown -R pi:pi /home/pi/.config/pipewire
chown -R pi:pi /home/pi/.config/wireplumber
chmod -R 755 /home/pi/.config/pipewire
chmod -R 755 /home/pi/.config/wireplumber

echo "Step 7: Enabling real-time scheduling..."
# Add user to realtime group if not already
usermod -a -G audio pi 2>/dev/null || true

# Set realtime limits
cat > /etc/security/limits.d/95-pipewire.conf << EOF
@audio - rtprio 95
@audio - memlock unlimited
@audio - nice -19
EOF

echo "Step 8: Updating system audio configuration..."
# Ensure PipeWire is the default
mkdir -p /etc/pipewire
cat > /etc/pipewire/media-session.d/with-pulseaudio << EOF
# Use PipeWire as PulseAudio replacement
context.modules = [
    {   name = libpipewire-module-protocol-pulse }
]
EOF

echo "Step 9: Restarting D-Bus..."
systemctl restart dbus

echo "Step 10: Starting PipeWire services..."
# Start as pi user
sudo -u pi XDG_RUNTIME_DIR=/run/user/$(id -u pi) systemctl --user daemon-reload
sudo -u pi XDG_RUNTIME_DIR=/run/user/$(id -u pi) systemctl --user enable pipewire pipewire-pulse wireplumber
sudo -u pi XDG_RUNTIME_DIR=/run/user/$(id -u pi) systemctl --user start pipewire pipewire-pulse wireplumber

sleep 3

echo ""
echo "=== Checking Status ==="
echo ""

# Check if services are running
if sudo -u pi XDG_RUNTIME_DIR=/run/user/$(id -u pi) systemctl --user is-active --quiet pipewire; then
    echo -e "${GREEN}✓ PipeWire is running${NC}"
else
    echo -e "${RED}✗ PipeWire failed to start${NC}"
fi

if sudo -u pi XDG_RUNTIME_DIR=/run/user/$(id -u pi) systemctl --user is-active --quiet pipewire-pulse; then
    echo -e "${GREEN}✓ PipeWire-Pulse is running${NC}"
else
    echo -e "${RED}✗ PipeWire-Pulse failed to start${NC}"
fi

if sudo -u pi XDG_RUNTIME_DIR=/run/user/$(id -u pi) systemctl --user is-active --quiet wireplumber; then
    echo -e "${GREEN}✓ WirePlumber is running${NC}"
else
    echo -e "${RED}✗ WirePlumber failed to start${NC}"
fi

echo ""
echo "=== Recent Logs ==="
sudo -u pi XDG_RUNTIME_DIR=/run/user/$(id -u pi) journalctl --user -u pipewire -u wireplumber -n 20 --no-pager

echo ""
echo -e "${GREEN}Fix completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Check status: sudo -u pi XDG_RUNTIME_DIR=/run/user/1000 systemctl --user status pipewire wireplumber"
echo "2. View logs: sudo -u pi XDG_RUNTIME_DIR=/run/user/1000 journalctl --user -u wireplumber -f"
echo "3. Test audio: speaker-test -c2 -t wav"
echo ""
echo "If issues persist, reboot: sudo reboot"
