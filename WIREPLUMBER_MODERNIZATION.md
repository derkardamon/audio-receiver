# WirePlumber Configuration Update

## Overview

This project has been updated to be compatible with modern WirePlumber (0.5.0+). The old Lua configuration files have been removed as they are no longer supported.

## What Changed

### Removed

- `configs/wireplumber/bluetooth.lua.d/50-bluez-config.lua`
- `configs/wireplumber/main.lua.d/50-bluez-config.lua`
- `configs/wireplumber/main.lua.d/51-alsa-hifiberry.lua`

These Lua configuration files are incompatible with WirePlumber 0.5+ and were causing warnings in system logs.

### Why This Is Fine

Modern WirePlumber 0.5+ uses a new configuration system based on JSON/TOML files and has excellent defaults for:

1. **Bluetooth Audio** - Automatically detects and prioritizes high-quality codecs (LDAC, aptX HD, aptX, AAC, SBC)
2. **Hardware Detection** - Automatically identifies and configures audio devices including HiFiBerry DAC
3. **Profile Selection** - Automatically selects the best audio profile for each device
4. **Auto-switching** - Seamlessly switches between audio sources

The Bluetooth configuration in `/etc/bluetooth/main.conf` and PipeWire configuration files still provide all necessary customization for this audio receiver setup.

## Current Configuration

The audio receiver now relies on:

1. **BlueZ Configuration** (`/etc/bluetooth/main.conf`)
   - Enables auto-pairing
   - Configures Bluetooth adapter settings
   - Sets device class for audio receiver

2. **PipeWire Configuration** (`/etc/pipewire/*.conf`)
   - Audio format and rate settings
   - Buffer configuration
   - Module loading

3. **ALSA Configuration** (`/etc/modprobe.d/alsa-base.conf`)
   - Sound card ordering
   - Ensures HiFiBerry is card 0

4. **WirePlumber** (system defaults)
   - Modern WirePlumber 0.5+ handles everything automatically
   - No custom configuration needed

## Verifying WirePlumber Operation

Check WirePlumber status:

```bash
systemctl --user status wireplumber
```

View WirePlumber logs:

```bash
journalctl --user -u wireplumber -f
```

List audio devices detected by WirePlumber:

```bash
wpctl status
```

## If You Need Custom WirePlumber Configuration

For WirePlumber 0.5+, create configuration files in:

```
~/.config/wireplumber/wireplumber.conf.d/
```

Or system-wide:

```
/etc/wireplumber/wireplumber.conf.d/
```

Use the modern JSON/TOML format. See: https://pipewire.pages.freedesktop.org/wireplumber/

## Benefits of This Update

1. **No More Warnings** - Eliminates "Old configuration file detected" warnings
2. **Better Compatibility** - Works with current and future WirePlumber versions
3. **Automatic Updates** - WirePlumber defaults improve over time without needing config changes
4. **Simpler Maintenance** - Less custom configuration to maintain
5. **Modern Features** - Access to latest WirePlumber features and optimizations

## Migration Notes

If you previously installed this project with the old Lua configs, you can safely remove them:

```bash
sudo rm -rf /etc/wireplumber/bluetooth.lua.d
sudo rm -rf /etc/wireplumber/main.lua.d
```

Then restart WirePlumber:

```bash
systemctl --user restart wireplumber
```

The audio receiver will continue to work with default WirePlumber configuration, which is optimized for Bluetooth audio scenarios.
