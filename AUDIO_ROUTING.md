# Audio Routing Guide

This guide explains how audio routing works on the Raspberry Pi Audio Receiver and how to troubleshoot routing issues.

## Default Configuration

The system is configured to route audio in this order:

1. **Bluetooth A2DP Input** → **HiFiBerry DAC Output**
2. **Any other audio source** → **HiFiBerry DAC Output**

HDMI audio is disabled by default to prevent conflicts.

## Audio Flow

```
Phone/Tablet (Bluetooth)
    ↓
Bluetooth A2DP Sink (BlueZ)
    ↓
PipeWire (Audio Server)
    ↓
WirePlumber (Session Manager)
    ↓
ALSA (Linux Audio Driver)
    ↓
HiFiBerry DAC+ ADC Pro
    ↓
Your Amplifier/Speakers
```

## Checking Audio Devices

### List All Audio Cards

```bash
aplay -l
```

Expected output:
```
**** List of PLAYBACK Hardware Devices ****
card 0: sndrpihifiberry [snd_rpi_hifiberry_dacplusadcpro], device 0: HiFiBerry DAC+ADC Pro HiFi multicodec-0 []
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```

### List PipeWire Sinks

```bash
pactl list sinks short
```

Expected output should show HiFiBerry as the primary sink:
```
0   alsa_output.platform-soc_sound.stereo-fallback  module-alsa-card.c  s16le 2ch 48000Hz  RUNNING
```

### Check Default Sink

```bash
pactl info | grep "Default Sink"
```

Should show the HiFiBerry device.

## Testing Audio Output

### Test HiFiBerry Directly (ALSA)

Bypass PipeWire and test the hardware directly:

```bash
speaker-test -c2 -t wav -D hw:0,0
```

This should produce sound from your HiFiBerry output. If this doesn't work, you have a hardware issue.

### Test Through PipeWire

Test the full audio stack:

```bash
speaker-test -c2 -t wav
```

This should also produce sound through HiFiBerry. If this works but the direct test doesn't, you have a PipeWire configuration issue.

## Common Issues

### Issue 1: Audio Goes to HDMI

**Symptoms:**
- `speaker-test` plays through HDMI/monitor speakers
- HiFiBerry is detected but not used

**Diagnosis:**

```bash
# Check which device is being used
pactl list sinks short

# If you see vc4-hdmi listed, that's the problem
```

**Solution:**

Run the fix script:
```bash
cd ~/audio-receiver
sudo ./scripts/fix-pipewire.sh
```

This will:
- Install WirePlumber config that disables HDMI
- Set HiFiBerry as highest priority
- Restart audio services

**Manual Fix:**

```bash
# Disable HDMI audio in boot config
sudo nano /boot/config.txt

# Add or uncomment:
hdmi_drive=1
hdmi_ignore_hotplug=1

# Reboot
sudo reboot
```

### Issue 2: No Sound at All

**Diagnosis Steps:**

1. **Check if HiFiBerry is detected:**
   ```bash
   aplay -l
   ```
   Should show `sndrpihifiberry`

2. **Check PipeWire is running:**
   ```bash
   systemctl --user status pipewire
   systemctl --user status wireplumber
   ```

3. **Check for errors:**
   ```bash
   journalctl --user -u pipewire -n 50
   journalctl --user -u wireplumber -n 50
   ```

4. **Test hardware directly:**
   ```bash
   speaker-test -c2 -t wav -D hw:0,0
   ```

**Solution:**

If hardware test fails, check:
- HiFiBerry is properly seated on GPIO pins
- `/boot/config.txt` has `dtoverlay=hifiberry-dacplusadcpro`
- Internal audio is disabled (`dtoverlay=disable-bt`)
- Reboot after any `/boot/config.txt` changes

If hardware test works but PipeWire test fails:
```bash
cd ~/audio-receiver
sudo ./scripts/fix-pipewire.sh
```

### Issue 3: Bluetooth Connects But No Audio

**Symptoms:**
- Phone shows "Connected"
- No sound plays
- No error messages

**Diagnosis:**

```bash
# Check if Bluetooth audio node is created
pactl list sinks short | grep bluez

# Check WirePlumber status
journalctl --user -u wireplumber -n 50
```

**Solution:**

```bash
# Restart audio stack
systemctl --user restart pipewire pipewire-pulse wireplumber

# Disconnect and reconnect Bluetooth device
# Try playing audio again
```

If still not working:
```bash
cd ~/audio-receiver
sudo ./scripts/fix-pipewire.sh
sudo systemctl restart bluetooth
```

### Issue 4: Poor Audio Quality / Crackling

**Diagnosis:**

```bash
# Check current codec
pactl list sinks | grep -i codec

# Check for buffer underruns
journalctl --user -u pipewire --since "5 minutes ago" | grep -i underrun
```

**Solution:**

Increase buffer size:
```bash
nano ~/.config/pipewire/pipewire.conf
```

Change:
```
default.clock.quantum = 2048
default.clock.min-quantum = 512
```

Restart:
```bash
systemctl --user restart pipewire
```

## Advanced Configuration

### Force Specific Sample Rate

Edit `~/.config/pipewire/pipewire.conf`:

```
default.clock.rate = 48000
default.clock.allowed-rates = [ 44100 48000 ]
```

Common rates:
- 44100 Hz: CD quality
- 48000 Hz: Professional audio standard
- 96000 Hz: High-resolution (requires DAC support)

### Set Default Sink Manually

```bash
# List available sinks
pactl list sinks short

# Set default (replace with your sink name)
pactl set-default-sink alsa_output.platform-soc_sound.stereo-fallback

# Make it persistent
mkdir -p ~/.config/pipewire/pipewire-pulse.conf.d
cat > ~/.config/pipewire/pipewire-pulse.conf.d/default-sink.conf << EOF
pulse.cmd = [
    { cmd = "load-module" args = "module-always-sink" }
    { cmd = "set-default-sink" args = "alsa_output.platform-soc_sound.stereo-fallback" }
]
EOF
```

### View Real-Time Audio Graph

```bash
# Install graph tool
sudo apt-get install pipewire-media-session-graph

# View connections
wpctl status
```

## Configuration Files

### PipeWire Main Config
- System: `/etc/pipewire/pipewire.conf`
- User: `~/.config/pipewire/pipewire.conf`

### WirePlumber Configs
- Bluetooth: `~/.config/wireplumber/main.lua.d/50-bluez-config.lua`
- HiFiBerry: `~/.config/wireplumber/main.lua.d/51-alsa-hifiberry.lua`

### Bluetooth Config
- Main: `/etc/bluetooth/main.conf`

## Monitoring Audio in Real-Time

### Watch PipeWire Logs

```bash
journalctl --user -u pipewire -f
```

### Watch WirePlumber Logs

```bash
journalctl --user -u wireplumber -f
```

### Monitor Bluetooth Connections

```bash
journalctl -u bluetooth -f
```

### View Audio Statistics

```bash
# Current playback stats
pactl list sink-inputs

# Sink status
pactl list sinks

# All audio nodes
pw-dump
```

## Getting Help

If you're still having audio issues:

1. Run diagnostics:
   ```bash
   ./scripts/check-status.sh
   ```

2. Gather logs:
   ```bash
   journalctl --user -u pipewire -n 100 > pipewire-log.txt
   journalctl --user -u wireplumber -n 100 > wireplumber-log.txt
   aplay -l > devices.txt
   pactl list sinks > sinks.txt
   ```

3. Open an issue on GitHub with:
   - Description of the problem
   - Output from step 2
   - Your Raspberry Pi model
   - HiFiBerry model

## References

- [PipeWire Documentation](https://docs.pipewire.org/)
- [WirePlumber Documentation](https://pipewire.pages.freedesktop.org/wireplumber/)
- [HiFiBerry Documentation](https://www.hifiberry.com/docs/)
- [BlueZ Documentation](http://www.bluez.org/)
