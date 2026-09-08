#!/bin/bash
# Diagnose and fix PipeWire issues

set -e

echo "=== PipeWire Diagnostics ==="
echo

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do not run this script as root. Run as your regular user."
    exit 1
fi

echo "1. Checking user runtime directory..."
if [ ! -d "/run/user/$UID" ]; then
    echo "   ERROR: Runtime directory /run/user/$UID does not exist"
    echo "   This usually means you need to log in properly (not via 'su')"
else
    echo "   ✓ Runtime directory exists"
fi

echo
echo "2. Checking environment variables..."
if [ -z "$XDG_RUNTIME_DIR" ]; then
    echo "   WARNING: XDG_RUNTIME_DIR not set"
    export XDG_RUNTIME_DIR="/run/user/$UID"
    echo "   Setting to: $XDG_RUNTIME_DIR"
else
    echo "   ✓ XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR"
fi

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    echo "   WARNING: DBUS_SESSION_BUS_ADDRESS not set"
else
    echo "   ✓ DBUS_SESSION_BUS_ADDRESS is set"
fi

echo
echo "3. Checking PipeWire processes..."
if pgrep -x pipewire > /dev/null; then
    echo "   ✓ PipeWire is running (PID: $(pgrep -x pipewire))"
else
    echo "   ✗ PipeWire is NOT running"
fi

if pgrep -x wireplumber > /dev/null; then
    echo "   ✓ WirePlumber is running (PID: $(pgrep -x wireplumber))"
else
    echo "   ✗ WirePlumber is NOT running"
fi

echo
echo "4. Checking systemd user services..."
export XDG_RUNTIME_DIR="/run/user/$UID"
systemctl --user status pipewire.service 2>&1 | grep -E "(Active:|Loaded:|Main PID:)" || echo "   Cannot query systemd"

echo
echo "5. Attempting to start PipeWire..."
systemctl --user restart pipewire pipewire-pulse wireplumber 2>&1 || {
    echo "   ERROR: Failed to start services via systemd"
    echo
    echo "   Trying manual start..."
    killall -9 pipewire pipewire-pulse wireplumber 2>/dev/null || true
    sleep 1
    /usr/bin/pipewire &
    sleep 1
    /usr/bin/pipewire-pulse &
    sleep 1
    /usr/bin/wireplumber &
    sleep 2
}

echo
echo "6. Testing connection..."
sleep 2
if pactl info > /dev/null 2>&1; then
    echo "   ✓ PipeWire is responding!"
    echo
    pactl info | grep "Server Name:"
    pactl info | grep "Default Sink:"
    echo
    echo "Available sinks:"
    pactl list sinks short
else
    echo "   ✗ Still cannot connect to PipeWire"
    echo
    echo "=== Troubleshooting Steps ==="
    echo "1. Make sure you're logged in via SSH or direct console (not 'su')"
    echo "2. Check logs: journalctl --user -u pipewire -u wireplumber --since '5 min ago'"
    echo "3. Try rebooting the system"
fi

echo
echo "=== End Diagnostics ==="
