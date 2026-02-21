# Audio Fix Summary

## Your Issues

1. **PipeWire showing "Old configuration format" warning**
2. **PipeWire connection timeout errors**
3. **Audio routing to HDMI instead of HiFiBerry DAC**

## What Was Fixed

### 1. Modern WirePlumber Configuration
Created new WirePlumber config files using the modern format:
- `configs/wireplumber/main.lua.d/50-bluez-config.lua` - Bluetooth audio config
- `configs/wireplumber/main.lua.d/51-alsa-hifiberry.lua` - HiFiBerry routing config

### 2. Audio Routing Priority
Added configuration to:
- Set HiFiBerry as highest priority audio device
- Disable HDMI audio output
- Ensure all Bluetooth audio routes to HiFiBerry

### 3. Automated Fix Script
Updated `scripts/fix-pipewire.sh` to:
- Stop all PipeWire services cleanly
- Backup old configurations
- Install modern config files
- Clean state directories
- Restart services properly
- Copy the new HiFiBerry routing config

### 4. Installation Updates
Updated `install.sh` to install all config files including:
- Modern WirePlumber Bluetooth config
- HiFiBerry routing config

### 5. Documentation
Created comprehensive troubleshooting docs:
- Updated `TROUBLESHOOTING.md` with PipeWire and audio routing sections
- Created new `AUDIO_ROUTING.md` guide
- Updated `README.md` with quick fixes

## How to Apply the Fix

Run this on your Raspberry Pi:

```bash
cd ~/audio-receiver
git pull
sudo ./scripts/fix-pipewire.sh
```

## What the Script Does

1. Stops PipeWire, PipeWire-Pulse, and WirePlumber services
2. Backs up your current configs to `~/.config/pipewire-backup-[timestamp]`
3. Removes old configuration directories
4. Installs fresh configs with:
   - Modern WirePlumber Bluetooth configuration
   - HiFiBerry priority routing
5. Sets proper permissions
6. Configures real-time audio scheduling
7. Restarts all services
8. Shows status and recent logs

## Expected Results

After running the fix script:

1. **No more "Old configuration format" warning**
2. **No more connection timeout errors**
3. **Audio routes to HiFiBerry automatically**
4. **speaker-test outputs to HiFiBerry, not HDMI**

## Verification Commands

```bash
# Check services are running
systemctl --user status pipewire wireplumber

# Check for errors (should be clean)
journalctl --user -u wireplumber -n 20

# Verify audio devices
aplay -l

# Test audio output (should play through HiFiBerry)
speaker-test -c2 -t wav

# List available sinks
pactl list sinks short
```

## If Problems Persist

1. **Check HiFiBerry is detected:**
   ```bash
   aplay -l
   # Should show: card 0: sndrpihifiberry
   ```

2. **Test hardware directly:**
   ```bash
   speaker-test -c2 -t wav -D hw:0,0
   # Should output to HiFiBerry
   ```

3. **Check boot config:**
   ```bash
   cat /boot/config.txt | grep hifiberry
   # Should show: dtoverlay=hifiberry-dacplusadcpro
   ```

4. **If nothing works, reboot:**
   ```bash
   sudo reboot
   ```

## Manual Configuration

If the script doesn't work, manually configure:

```bash
# Stop services
systemctl --user stop pipewire pipewire-pulse wireplumber

# Clean old configs
rm -rf ~/.config/pipewire ~/.config/wireplumber
rm -rf ~/.local/state/pipewire ~/.local/state/wireplumber

# Copy new configs
mkdir -p ~/.config/wireplumber/main.lua.d
cp ~/audio-receiver/configs/wireplumber/main.lua.d/*.lua ~/.config/wireplumber/main.lua.d/

# Restart
systemctl --user daemon-reload
systemctl --user restart pipewire pipewire-pulse wireplumber
```

## Additional Documentation

- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Complete troubleshooting guide
- **[AUDIO_ROUTING.md](AUDIO_ROUTING.md)** - Detailed audio routing information
- **[README.md](README.md)** - Main project documentation

## Changes Made to Repository

New files:
- `configs/wireplumber/main.lua.d/50-bluez-config.lua`
- `configs/wireplumber/main.lua.d/51-alsa-hifiberry.lua`
- `AUDIO_ROUTING.md`

Updated files:
- `scripts/fix-pipewire.sh`
- `install.sh`
- `TROUBLESHOOTING.md`
- `README.md`

All changes are backwards compatible with existing installations.
