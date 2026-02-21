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

# Detect the actual user (not root)
if [ "$SUDO_USER" ]; then
    ACTUAL_USER="$SUDO_USER"
    ACTUAL_UID=$(id -u "$SUDO_USER")
else
    echo -e "${RED}Please run with sudo${NC}"
    exit 1
fi

USER_HOME=$(eval echo ~$ACTUAL_USER)

echo "Configuring for user: $ACTUAL_USER"
echo "Home directory: $USER_HOME"
echo ""

# Get the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "Step 1: Stopping PipeWire services..."
sudo -u "$ACTUAL_USER" XDG_RUNTIME_DIR="/run/user/$ACTUAL_UID" systemctl --user stop pipewire pipewire-pulse wireplumber 2>/dev/null || true
killall -9 pipewire pipewire-pulse wireplumber 2>/dev/null || true
sleep 2

echo "Step 2: Backing up old configurations..."
BACKUP_DIR="$USER_HOME/.config/pipewire-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -d "$USER_HOME/.config/pipewire" ]; then
    cp -r "$USER_HOME/.config/pipewire"/* "$BACKUP_DIR/" 2>/dev/null || true
    echo "Backup saved to: $BACKUP_DIR"
fi

if [ -d "$USER_HOME/.config/wireplumber" ]; then
    cp -r "$USER_HOME/.config/wireplumber"/* "$BACKUP_DIR/" 2>/dev/null || true
fi

echo "Step 3: Cleaning old configurations..."
rm -rf "$USER_HOME/.config/pipewire"
rm -rf "$USER_HOME/.config/wireplumber"
rm -rf "$USER_HOME/.local/state/pipewire"
rm -rf "$USER_HOME/.local/state/wireplumber"

echo "Step 4: Creating new configuration directories..."
mkdir -p "$USER_HOME/.config/wireplumber/main.lua.d"
mkdir -p "$USER_HOME/.config/wireplumber/bluetooth.lua.d"

echo "Step 5: Installing updated configurations..."

# Copy WirePlumber configs from repo
if [ -f "$REPO_ROOT/configs/wireplumber/bluetooth.lua.d/50-bluez-config.lua" ]; then
    cp "$REPO_ROOT/configs/wireplumber/bluetooth.lua.d/50-bluez-config.lua" "$USER_HOME/.config/wireplumber/bluetooth.lua.d/"
    echo "Copied bluetooth config"
fi

if [ -f "$REPO_ROOT/configs/wireplumber/main.lua.d/50-bluez-config.lua" ]; then
    cp "$REPO_ROOT/configs/wireplumber/main.lua.d/50-bluez-config.lua" "$USER_HOME/.config/wireplumber/main.lua.d/"
    echo "Copied bluetooth main config"
fi

if [ -f "$REPO_ROOT/configs/wireplumber/main.lua.d/51-alsa-hifiberry.lua" ]; then
    cp "$REPO_ROOT/configs/wireplumber/main.lua.d/51-alsa-hifiberry.lua" "$USER_HOME/.config/wireplumber/main.lua.d/"
    echo "Copied HiFiBerry config"
fi

echo "Step 6: Setting correct permissions..."
if id "$ACTUAL_USER" &>/dev/null; then
    chown -R "$ACTUAL_USER:$ACTUAL_USER" "$USER_HOME/.config/wireplumber"
else
    echo -e "${YELLOW}Warning: User $ACTUAL_USER not found, skipping chown${NC}"
fi
chmod -R 755 "$USER_HOME/.config/wireplumber"

echo "Step 7: Enabling real-time scheduling..."
usermod -a -G audio "$ACTUAL_USER" 2>/dev/null || true

# Set realtime limits
cat > /etc/security/limits.d/95-pipewire.conf << EOF
@audio - rtprio 95
@audio - memlock unlimited
@audio - nice -19
EOF

echo "Step 8: Starting PipeWire services..."
sudo -u "$ACTUAL_USER" XDG_RUNTIME_DIR="/run/user/$ACTUAL_UID" systemctl --user daemon-reload
sudo -u "$ACTUAL_USER" XDG_RUNTIME_DIR="/run/user/$ACTUAL_UID" systemctl --user restart pipewire pipewire-pulse wireplumber

sleep 3

echo ""
echo "=== Checking Status ==="
echo ""

# Check if services are running
if sudo -u "$ACTUAL_USER" XDG_RUNTIME_DIR="/run/user/$ACTUAL_UID" systemctl --user is-active --quiet pipewire; then
    echo -e "${GREEN}✓ PipeWire is running${NC}"
else
    echo -e "${RED}✗ PipeWire failed to start${NC}"
fi

if sudo -u "$ACTUAL_USER" XDG_RUNTIME_DIR="/run/user/$ACTUAL_UID" systemctl --user is-active --quiet pipewire-pulse; then
    echo -e "${GREEN}✓ PipeWire-Pulse is running${NC}"
else
    echo -e "${RED}✗ PipeWire-Pulse failed to start${NC}"
fi

if sudo -u "$ACTUAL_USER" XDG_RUNTIME_DIR="/run/user/$ACTUAL_UID" systemctl --user is-active --quiet wireplumber; then
    echo -e "${GREEN}✓ WirePlumber is running${NC}"
else
    echo -e "${RED}✗ WirePlumber failed to start${NC}"
fi

echo ""
echo "=== Recent Logs ==="
sudo -u "$ACTUAL_USER" XDG_RUNTIME_DIR="/run/user/$ACTUAL_UID" journalctl --user -u pipewire -u wireplumber -n 20 --no-pager

echo ""
echo -e "${GREEN}Fix completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Check status: systemctl --user status pipewire wireplumber"
echo "2. View logs: journalctl --user -u wireplumber -f"
echo "3. Test audio: speaker-test -c2 -t wav"
echo ""
echo "If issues persist, reboot: sudo reboot"
