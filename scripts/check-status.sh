#!/bin/bash

# Status Check Script for Raspberry Pi Audio Receiver

echo "========================================="
echo "Raspberry Pi Audio Receiver Status Check"
echo "========================================="
echo ""

# Check Bluetooth service
echo "--- Bluetooth Service Status ---"
systemctl is-active --quiet bluetooth && echo "✓ Bluetooth service: RUNNING" || echo "✗ Bluetooth service: STOPPED"
systemctl is-active --quiet bluetooth-autopair && echo "✓ Auto-pair service: RUNNING" || echo "✗ Auto-pair service: STOPPED"
echo ""

# Check PipeWire services
echo "--- PipeWire Services Status ---"
systemctl --user is-active --quiet pipewire && echo "✓ PipeWire: RUNNING" || echo "✗ PipeWire: STOPPED"
systemctl --user is-active --quiet pipewire-pulse && echo "✓ PipeWire-Pulse: RUNNING" || echo "✗ PipeWire-Pulse: STOPPED"
systemctl --user is-active --quiet wireplumber && echo "✓ WirePlumber: RUNNING" || echo "✗ WirePlumber: STOPPED"
echo ""

# Check audio devices
echo "--- Audio Devices ---"
aplay -l 2>/dev/null | grep -i "hifiberry" && echo "✓ HiFiBerry detected" || echo "✗ HiFiBerry not detected"
echo ""

# Check Bluetooth adapters
echo "--- Bluetooth Adapters ---"
hciconfig 2>/dev/null | head -n 1
echo ""

# Check paired devices
echo "--- Paired Bluetooth Devices ---"
bluetoothctl devices 2>/dev/null | head -n 10
echo ""

# Check if discoverable
echo "--- Bluetooth Discoverable Status ---"
bluetoothctl show 2>/dev/null | grep "Discoverable"
echo ""

echo "========================================="
echo "Status check complete"
echo "========================================="
