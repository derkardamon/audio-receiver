#!/bin/bash

# Unpair all Bluetooth devices

echo "========================================="
echo "Unpairing all Bluetooth devices"
echo "========================================="

# Get list of paired devices
devices=$(bluetoothctl devices | cut -d ' ' -f 2)

if [ -z "$devices" ]; then
    echo "No devices to unpair"
    exit 0
fi

# Unpair each device
for device in $devices; do
    echo "Removing device: $device"
    bluetoothctl remove "$device"
done

echo ""
echo "All devices unpaired"
echo "========================================="
