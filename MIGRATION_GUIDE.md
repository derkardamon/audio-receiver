# Migration Guide

## Updating from Older Versions

If you installed this project before February 2026, you may have outdated WirePlumber Lua configuration files that are no longer compatible with modern WirePlumber versions.

## What Changed

**Old WirePlumber Configuration:**
- Used Lua files in `/etc/wireplumber/bluetooth.lua.d/` and `/etc/wireplumber/main.lua.d/`
- Compatible with WirePlumber 0.4.x
- Required custom configuration for Bluetooth audio

**New WirePlumber Configuration:**
- No custom configuration files needed
- Compatible with WirePlumber 0.5.0+
- Uses modern JSON/TOML configuration system
- Relies on excellent built-in defaults

## Migration Steps

### 1. Check Your Current Setup

Check if you have old WirePlumber configs:

```bash
ls -la /etc/wireplumber/
```

If you see `bluetooth.lua.d` or `main.lua.d` directories, you need to migrate.

### 2. Remove Old Configuration

```bash
# Remove outdated Lua configs
sudo rm -rf /etc/wireplumber/bluetooth.lua.d
sudo rm -rf /etc/wireplumber/main.lua.d

# Restart WirePlumber
systemctl --user restart wireplumber
```

### 3. Update Installation

Pull the latest code:

```bash
cd ~/audio-receiver
git pull
```

Re-run the installation (it will skip WirePlumber config now):

```bash
sudo ./install.sh
```

### 4. Verify Everything Works

Check that the warnings are gone:

```bash
systemctl --user status wireplumber
```

You should no longer see "Old configuration file detected" warnings.

Test audio:

```bash
./scripts/check-audio.sh
```

Connect a Bluetooth device and test audio playback.

## What If It Doesn't Work?

### Audio Not Working After Migration

If audio stops working after removing the old configs:

1. **Restart all services:**
```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

2. **Check audio devices:**
```bash
wpctl status
```

3. **Reconnect Bluetooth device:**
   - Disconnect and reconnect your phone/tablet
   - The audio should work with default WirePlumber settings

### HiFiBerry Not Detected

If HiFiBerry stops working:

```bash
# Verify HiFiBerry is detected by ALSA
aplay -l

# Should show "card 0: sndrpihifiberry"
```

If not detected, check `/boot/config.txt`:

```bash
cat /boot/config.txt | grep hifiberry
```

Should show: `dtoverlay=hifiberry-dacplusadcpro`

### Rollback (If Needed)

If you need to temporarily rollback to old configs:

```bash
cd ~/audio-receiver
git log --oneline

# Find commit before WirePlumber removal (look for Feb 2026 commits)
git checkout <old-commit-hash>

# Reinstall
sudo ./install.sh
sudo reboot
```

However, this is NOT recommended as old Lua configs are deprecated.

## Benefits of Migrating

1. **No more warnings** - Clean system logs
2. **Better compatibility** - Works with current and future WirePlumber versions
3. **Automatic improvements** - WirePlumber defaults are continuously improved
4. **Less maintenance** - No custom configs to maintain
5. **Simpler troubleshooting** - Fewer moving parts

## Additional Resources

- `WIREPLUMBER_MODERNIZATION.md` - Detailed technical explanation
- `TROUBLESHOOTING.md` - Common issues and solutions
- Official WirePlumber docs: https://pipewire.pages.freedesktop.org/wireplumber/

## Questions?

If you encounter issues during migration, open an issue on GitHub with:
- Output of `systemctl --user status wireplumber`
- Output of `./scripts/check-audio.sh`
- Description of what's not working
