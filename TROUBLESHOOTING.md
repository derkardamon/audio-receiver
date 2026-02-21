# Troubleshooting Guide

Common issues and solutions for the Raspberry Pi Audio Receiver.

## Quick Diagnostics

Run these commands first to identify the issue:

```bash
# Check all services status
./scripts/check-status.sh

# Verify installation
./scripts/verify-installation.sh

# View recent errors
sudo journalctl -u bluetooth-autopair -n 50
```

---

## PipeWire Issues

### Error: "Old configuration format" or "Connection timeout"

**Symptoms:**
- `wireplumber: Old configuration format detected`
- `pipewire: Connection failure: Timeout`
- Audio not working after pairing

**Solution:**

```bash
cd ~/audio-receiver
sudo ./scripts/fix-pipewire.sh
```

This script will:
- Stop all PipeWire services
- Backup old configurations
- Install updated configs
- Restart services properly

**Manual fix if script fails:**

```bash
# Stop services
systemctl --user stop pipewire pipewire-pulse wireplumber

# Clean configs
rm -rf ~/.config/pipewire
rm -rf ~/.config/wireplumber
rm -rf ~/.local/state/pipewire
rm -rf ~/.local/state/wireplumber

# Copy fresh configs from repo
mkdir -p ~/.config/pipewire
mkdir -p ~/.config/wireplumber/main.lua.d
cp ~/audio-receiver/configs/pipewire/* ~/.config/pipewire/
cp ~/audio-receiver/configs/wireplumber/main.lua.d/* ~/.config/wireplumber/main.lua.d/

# Restart
systemctl --user daemon-reload
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### PipeWire Not Starting

**Check if running:**
```bash
systemctl --user status pipewire
systemctl --user status wireplumber
```

**Restart services:**
```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

**Check for errors:**
```bash
journalctl --user -u pipewire -n 50
journalctl --user -u wireplumber -n 50
```

### Audio Crackling or Dropouts

**Increase buffer size:**

Edit `~/.config/pipewire/pipewire.conf`:
```
default.clock.quantum = 2048
default.clock.min-quantum = 512
```

Then restart:
```bash
systemctl --user restart pipewire
```

### Audio Goes to HDMI Instead of HiFiBerry

**Symptoms:**
- `speaker-test` outputs to HDMI
- HiFiBerry is detected but not used
- `aplay -l` shows both HDMI and HiFiBerry

**Solution:**

The fix-pipewire script now includes HiFiBerry routing configuration:

```bash
cd ~/audio-receiver
sudo ./scripts/fix-pipewire.sh
```

**Manual fix:**

```bash
# Check which devices are available
aplay -l

# You should see card 0 as sndrpihifiberry
# Manually test HiFiBerry
speaker-test -c2 -t wav -D hw:0,0

# If that works, force PipeWire to use HiFiBerry
pactl set-default-sink alsa_output.platform-soc_sound.stereo-fallback
```

**Verify the fix:**

```bash
# List available sinks
pactl list sinks short

# Test with speaker-test
speaker-test -c2 -t wav

# Should now output to HiFiBerry, not HDMI
```

---

## Bluetooth Issues

### Device Not Discoverable

**Symptoms:** Your phone/tablet cannot find "RaspberryPi-Audio"

**Solutions:**

1. Check Bluetooth service status:
```bash
sudo systemctl status bluetooth
```

2. Restart Bluetooth:
```bash
sudo systemctl restart bluetooth
sudo systemctl restart bluetooth-autopair
```

3. Manually make discoverable:
```bash
bluetoothctl
discoverable on
pairable on
```

4. Check if USB Bluetooth adapter is recognized:
```bash
hciconfig
lsusb | grep -i bluetooth
```

### Auto-Pairing Not Working

**Symptoms:** Connection requires pairing code or fails

**Solutions:**

1. Check auto-pair service:
```bash
sudo systemctl status bluetooth-autopair
```

2. View auto-pair logs:
```bash
journalctl -u bluetooth-autopair -f
```

3. Restart the service:
```bash
sudo systemctl restart bluetooth-autopair
```

4. Verify configuration in `/etc/bluetooth/main.conf`:
```
PairableTimeout = 0
DiscoverableTimeout = 0
```

### Cannot Pair or Connect

**Symptoms:** Pairing fails or connection drops immediately

**Solutions:**

1. Remove old pairings:
```bash
./scripts/unpair-all.sh
```

2. Restart Bluetooth stack:
```bash
sudo systemctl restart bluetooth
sudo systemctl restart bluetooth-autopair
```

3. Check Bluetooth logs:
```bash
journalctl -u bluetooth -n 50
```

4. Try manual pairing:
```bash
bluetoothctl
agent NoInputNoOutput
default-agent
scan on
# Wait for device to appear
pair [DEVICE_MAC]
trust [DEVICE_MAC]
connect [DEVICE_MAC]
```

## Audio Issues

### No Sound Output

**Symptoms:** Device connects but no audio plays

**Solutions:**

1. Check if HiFiBerry is detected:
```bash
aplay -l
```

Should show: `card 0: sndrpihifiberry`

2. Test audio output:
```bash
speaker-test -c2 -twav
```

3. Check PipeWire status:
```bash
systemctl --user status pipewire
systemctl --user status pipewire-pulse
```

4. Restart PipeWire:
```bash
systemctl --user restart pipewire
systemctl --user restart pipewire-pulse
systemctl --user restart wireplumber
```

5. Check for ALSA errors:
```bash
dmesg | grep -i audio
dmesg | grep -i hifiberry
```

### HiFiBerry Not Detected

**Symptoms:** `aplay -l` doesn't show HiFiBerry

**Solutions:**

1. Check `/boot/config.txt`:
```bash
cat /boot/config.txt | grep hifiberry
```

Should show: `dtoverlay=hifiberry-dacplusadcpro`

2. Check for conflicting overlays:
```bash
cat /boot/config.txt | grep dtparam=audio
```

If present, comment it out or remove it.

3. Verify internal audio is disabled:
```bash
cat /boot/config.txt | grep disable-bt
```

Should show: `dtoverlay=disable-bt`

4. Reboot after changes:
```bash
sudo reboot
```

### Poor Audio Quality

**Symptoms:** Audio sounds distorted, crackling, or stuttering

**Solutions:**

1. Adjust buffer size in `/etc/pipewire/pipewire.conf`:
```
default.clock.quantum = 2048  # Increase for stability
```

2. Check for underruns:
```bash
journalctl -u pipewire --since "5 minutes ago"
```

3. Reduce CPU load by stopping unnecessary services

4. Try different sample rate in `/etc/pipewire/pipewire.conf`:
```
default.clock.rate = 44100  # or 48000
```

5. Restart PipeWire:
```bash
systemctl --user restart pipewire
```

### Volume Control Not Working

**Symptoms:** Changing volume on phone doesn't affect output

**Solutions:**

1. Check if AVRCP is enabled in `/etc/bluetooth/main.conf`

2. Disconnect and reconnect the device

3. Try controlling volume from Raspberry Pi:
```bash
pactl set-sink-volume @DEFAULT_SINK@ 50%
```

## Connection Issues

### Second Device Cannot Connect

**Symptoms:** Second device fails to connect while first is connected

**Expected Behavior:** This is normal - only one A2DP stream at a time.

**Solutions:**

1. Disconnect first device before connecting second
2. Second device will automatically disconnect first when it connects
3. This is by design for single-stream audio

### Connection Drops Frequently

**Symptoms:** Audio cuts out or device disconnects randomly

**Solutions:**

1. Check Bluetooth signal strength (move devices closer)

2. Check for USB power issues:
```bash
dmesg | grep -i usb
```

3. Use powered USB hub if needed

4. Increase ReconnectAttempts in `/etc/bluetooth/main.conf`:
```
ReconnectAttempts = 7
```

5. Check for interference from WiFi (try different WiFi channel)

### Device Connects But Shows as "Not Connected"

**Symptoms:** Pairing successful but audio doesn't work

**Solutions:**

1. Check PipeWire logs:
```bash
journalctl --user -u pipewire -f
```

2. Check if bluez_sink is created:
```bash
pactl list sinks short
```

3. Restart Bluetooth and PipeWire:
```bash
sudo systemctl restart bluetooth
systemctl --user restart pipewire
```

## Performance Issues

### High CPU Usage

**Symptoms:** System slow, audio stuttering

**Solutions:**

1. Check CPU usage:
```bash
top
```

2. Reduce PipeWire real-time priority in `/etc/pipewire/pipewire.conf`:
```
rt.prio = 70  # Lower value
```

3. Increase buffer size:
```
default.clock.quantum = 2048
```

4. Disable unnecessary services

### Audio Latency

**Symptoms:** Noticeable delay between video and audio

**Solutions:**

1. Reduce buffer size in `/etc/pipewire/pipewire.conf`:
```
default.clock.quantum = 512  # Lower value
```

2. Check real-time scheduling is enabled:
```bash
cat /etc/pipewire/pipewire.conf | grep rt.prio
```

3. Restart PipeWire:
```bash
systemctl --user restart pipewire
```

## Service Issues

### Services Not Starting on Boot

**Symptoms:** Must manually start services after reboot

**Solutions:**

1. Enable services:
```bash
sudo systemctl enable bluetooth
sudo systemctl enable bluetooth-autopair
```

2. Check for startup errors:
```bash
sudo systemctl status bluetooth
sudo systemctl status bluetooth-autopair
```

3. Check boot logs:
```bash
journalctl -b | grep bluetooth
```

### Permission Denied Errors

**Symptoms:** Commands fail with permission errors

**Solutions:**

1. Run with sudo:
```bash
sudo systemctl restart bluetooth
```

2. Check user groups:
```bash
groups $USER
```

Should include: `bluetooth`, `audio`

3. Add user to groups if missing:
```bash
sudo usermod -a -G bluetooth,audio $USER
```

4. Log out and back in for group changes to take effect

## Diagnostic Commands

### Full System Check

Run the comprehensive status check:
```bash
./scripts/check-status.sh
```

### View All Logs

```bash
# Bluetooth logs
journalctl -u bluetooth -f

# Auto-pair logs
journalctl -u bluetooth-autopair -f

# PipeWire logs
journalctl --user -u pipewire -f

# System logs
dmesg | tail -n 50
```

### Manual Bluetooth Test

```bash
bluetoothctl
power on
discoverable on
pairable on
agent NoInputNoOutput
default-agent
scan on
```

## Getting More Help

If none of these solutions work:

1. Gather diagnostic information:
```bash
./scripts/check-status.sh > diagnostics.txt
journalctl -u bluetooth -n 100 >> diagnostics.txt
journalctl -u bluetooth-autopair -n 100 >> diagnostics.txt
dmesg >> diagnostics.txt
```

2. Open an issue on GitHub with:
   - Description of the problem
   - What you've tried
   - Output from diagnostics.txt
   - Your Raspberry Pi model and OS version

3. Check existing issues on GitHub

## Recovery

### Complete Reset

If everything else fails:

1. Unpair all devices:
```bash
./scripts/unpair-all.sh
```

2. Uninstall completely:
```bash
sudo ./uninstall.sh
```

3. Reboot:
```bash
sudo reboot
```

4. Reinstall:
```bash
sudo ./install.sh
sudo reboot
```
