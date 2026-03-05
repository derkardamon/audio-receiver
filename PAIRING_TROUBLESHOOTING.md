# Bluetooth Pairing Troubleshooting Guide

## Quick Diagnostics

Run these commands to diagnose pairing issues:

```bash
# Check service status
sudo systemctl status bluetooth-autopair

# Check recent logs
sudo journalctl -u bluetooth-autopair -n 100

# Check Bluetooth status
bluetoothctl show

# Check if agent is registered
bluetoothctl agent on
```

## Common Issues and Solutions

### 1. Service Not Running

```bash
sudo systemctl enable bluetooth-autopair
sudo systemctl restart bluetooth-autopair
sudo systemctl status bluetooth-autopair
```

### 2. Bluetooth Not Discoverable

```bash
# Make device discoverable
bluetoothctl discoverable on
bluetoothctl pairable on

# Or permanently set in /etc/bluetooth/main.conf:
# Discoverable = true
# AlwaysPairable = yes
```

### 3. Agent Not Registered

Check logs for errors:
```bash
sudo journalctl -u bluetooth-autopair -f
```

Common errors:
- `dbus.exceptions.DBusException: org.bluez.Error.AlreadyExists`: Another agent is registered
- Python dependencies missing: Install `python3-dbus` and `python3-gi`

### 4. Pairing Request Not Reaching Agent

The device might be trying SSP (Secure Simple Pairing) which requires confirmation. Try:

```bash
# Stop the service temporarily
sudo systemctl stop bluetooth-autopair

# Manually run agent to see real-time output
sudo python3 /usr/local/bin/bluetooth-autopair.py
```

Then try pairing from your phone and watch the output.

### 5. Previous Pairing Conflicts

Remove old pairings:
```bash
# List paired devices
bluetoothctl devices

# Remove a device (replace XX:XX:XX:XX:XX:XX with device MAC)
bluetoothctl remove XX:XX:XX:XX:XX:XX

# Or remove all
bash /path/to/scripts/unpair-all.sh
```

### 6. Bluetooth Service Issues

```bash
# Restart Bluetooth service
sudo systemctl restart bluetooth

# Wait a few seconds
sleep 3

# Restart autopair service
sudo systemctl restart bluetooth-autopair
```

## Manual Pairing (Alternative)

If auto-pairing doesn't work, try manual pairing:

```bash
bluetoothctl
> agent NoInputNoOutput
> default-agent
> discoverable on
> pairable on
> scan on
# Wait for device to appear
> pair XX:XX:XX:XX:XX:XX
> trust XX:XX:XX:XX:XX:XX
> connect XX:XX:XX:XX:XX:XX
```

## Debugging Steps

1. **Check Python dependencies:**
   ```bash
   python3 -c "import dbus; import gi.repository.GLib; print('OK')"
   ```

2. **Test agent manually:**
   ```bash
   sudo systemctl stop bluetooth-autopair
   sudo python3 /usr/local/bin/bluetooth-autopair.py
   # Watch output while attempting to pair
   ```

3. **Check D-Bus permissions:**
   ```bash
   sudo dbus-send --system --print-reply \
     --dest=org.bluez /org/bluez \
     org.freedesktop.DBus.Introspectable.Introspect
   ```

4. **Verify Bluetooth is powered and pairable:**
   ```bash
   bluetoothctl show | grep -E "Powered|Discoverable|Pairable"
   ```

## Configuration Check

Verify `/etc/bluetooth/main.conf` has:
```ini
[General]
DiscoverableTimeout = 0
AlwaysPairable = yes
Discoverable = true

[Policy]
AutoEnable=true
```

After changes:
```bash
sudo systemctl restart bluetooth
sleep 3
sudo systemctl restart bluetooth-autopair
```

## Complete Reset

If all else fails:

```bash
# Stop services
sudo systemctl stop bluetooth-autopair
sudo systemctl stop bluetooth

# Clear Bluetooth cache
sudo rm -rf /var/lib/bluetooth/*

# Restart
sudo systemctl start bluetooth
sleep 5
sudo systemctl start bluetooth-autopair

# Reconfigure
bluetoothctl discoverable on
bluetoothctl pairable on
```

## Still Not Working?

Check device-specific issues:
- Some phones require specific pairing methods
- Some devices don't support NoInputNoOutput
- Audio profiles might need manual connection after pairing

Try connecting after pairing:
```bash
# After device is paired (check with: bluetoothctl devices Paired)
bluetoothctl connect XX:XX:XX:XX:XX:XX
```
