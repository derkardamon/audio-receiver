#!/bin/bash

echo "========================================="
echo "Audio System Status Check"
echo "========================================="
echo ""

# Check if wpctl is available
if ! command -v wpctl &> /dev/null; then
    echo "⚠ wpctl not found. Install wireplumber package."
    echo ""
fi

echo "--- Audio Devices (ALSA) ---"
if command -v aplay &> /dev/null; then
    aplay -l
else
    echo "aplay not found"
fi
echo ""

echo "--- PipeWire Status ---"
if systemctl --user is-active --quiet pipewire; then
    echo "✓ PipeWire is running"
else
    echo "✗ PipeWire is NOT running"
fi

if systemctl --user is-active --quiet pipewire-pulse; then
    echo "✓ PipeWire PulseAudio compatibility is running"
else
    echo "✗ PipeWire PulseAudio compatibility is NOT running"
fi

if systemctl --user is-active --quiet wireplumber; then
    echo "✓ WirePlumber is running"
else
    echo "✗ WirePlumber is NOT running"
fi
echo ""

echo "--- PipeWire Devices and Streams ---"
if command -v wpctl &> /dev/null; then
    wpctl status
else
    echo "wpctl not available - install wireplumber"
fi
echo ""

echo "--- Sound Card Order ---"
if [ -f /proc/asound/cards ]; then
    cat /proc/asound/cards
else
    echo "No sound cards found"
fi
echo ""

echo "--- Active Kernel Modules ---"
echo "HiFiBerry:"
lsmod | grep -i snd_soc || echo "  No HiFiBerry module loaded"
echo ""
echo "Bluetooth:"
lsmod | grep -i bluetooth || echo "  No Bluetooth module loaded"
echo ""

echo "--- Recent Audio Errors ---"
journalctl --user -u pipewire -u wireplumber --since "5 minutes ago" | grep -i error | tail -10
echo ""

echo "========================================="
echo "Status check complete"
echo "========================================="
