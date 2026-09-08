#!/bin/bash

echo "=== Fixing Bluetooth Visibility Issues ==="

# Stop services
echo "Stopping Bluetooth services..."
sudo systemctl stop bluetooth-autopair 2>/dev/null
sudo systemctl stop bluetooth

# Clear any stale Bluetooth state
echo "Clearing Bluetooth cache..."
sudo rm -rf /var/lib/bluetooth/*/cache 2>/dev/null

# Reset the Bluetooth controller
echo "Resetting Bluetooth controller..."
sudo rfkill unblock bluetooth
sudo sh -c 'for f in /var/lib/systemd/rfkill/*bluetooth; do echo 0 > "$f"; done' 2>/dev/null || true

# Restart Bluetooth service
echo "Starting Bluetooth service..."
sudo systemctl start bluetooth
sleep 2

# Configure Bluetooth settings
echo "Configuring Bluetooth for maximum visibility..."
bluetoothctl << EOF
power on
discoverable on
pairable on
agent NoInputNoOutput
default-agent
quit
EOF

# Make sure controller is in correct mode
echo "Setting controller mode..."
sudo hciconfig hci0 piscan
sudo hciconfig hci0 sspmode 1

# Start autopair service
echo "Starting autopair service..."
sudo systemctl start bluetooth-autopair

# Show status
echo -e "\n=== Bluetooth Status ==="
bluetoothctl show | grep -E "(Powered|Discoverable|Pairable|Name)"

echo -e "\n=== Controller Status ==="
hciconfig hci0 | grep -E "(UP|RUNNING|PSCAN|ISCAN)"

echo -e "\nDone! Try scanning from your iPhone now."
echo "Device name: PiuPiu-Audio"
