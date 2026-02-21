# Fresh Installation Guide

This guide walks you through wiping your SD card and performing a complete fresh installation of the Raspberry Pi Audio Receiver from scratch.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Backup Important Data](#backup-important-data)
3. [Wipe and Flash SD Card](#wipe-and-flash-sd-card)
4. [Initial Raspberry Pi Setup](#initial-raspberry-pi-setup)
5. [Install Audio Receiver](#install-audio-receiver)
6. [Verification](#verification)

## Prerequisites

### Required Hardware

- Raspberry Pi 4 Model B
- MicroSD card (16GB or larger recommended)
- MicroSD card reader for your computer
- HiFiBerry DAC+ ADC Pro
- Asus USB-BT500 Bluetooth adapter (or compatible)
- Power supply for Raspberry Pi
- Computer (Windows, Mac, or Linux)

### Required Software

- [Raspberry Pi Imager](https://www.raspberrypi.com/software/) (recommended)
- Or [balenaEtcher](https://www.balena.io/etcher/) (alternative)
- SSH client (PuTTY for Windows, or built-in terminal for Mac/Linux)

## Backup Important Data

**WARNING: This process will erase ALL data on your SD card!**

If you have any important data on your current Raspberry Pi:

```bash
# Backup important files via SSH
scp pi@raspberrypi.local:~/important-file.txt ./backup/

# Or backup entire directories
scp -r pi@raspberrypi.local:~/important-folder ./backup/
```

## Wipe and Flash SD Card

### Method 1: Using Raspberry Pi Imager (Recommended)

1. **Download and Install Raspberry Pi Imager**
   - Visit: https://www.raspberrypi.com/software/
   - Download for your operating system
   - Install and launch the application

2. **Prepare SD Card**
   - Insert your SD card into your computer's card reader
   - Launch Raspberry Pi Imager

3. **Select Operating System**
   - Click "Choose OS"
   - Select "Raspberry Pi OS (other)"
   - Select "Raspberry Pi OS Lite (64-bit)"
   - **Important**: Choose the **Lite** version (no desktop)

4. **Select Storage**
   - Click "Choose Storage"
   - Select your SD card
   - **Double-check you selected the correct drive!**

5. **Configure Settings (Important!)**
   - Click the gear icon ⚙️ (bottom right)
   - Configure these settings:

   **General:**
   - Set hostname: `audioreceiver` (or your preference)
   - Enable SSH: ✓ Use password authentication
   - Set username: `pi` (recommended)
   - Set password: [choose a secure password]
   - Configure wireless LAN:
     - SSID: [your WiFi network name]
     - Password: [your WiFi password]
     - Wireless LAN country: [your country code, e.g., US]
   - Set locale settings:
     - Time zone: [your timezone]
     - Keyboard layout: [your layout]

   **Services:**
   - Enable SSH: ✓ checked

6. **Write to SD Card**
   - Click "Save" to save settings
   - Click "Write"
   - Confirm the warning (this will erase the SD card)
   - Wait for the process to complete (5-10 minutes)
   - Click "Continue" when done

### Method 2: Using balenaEtcher (Alternative)

1. **Download Raspberry Pi OS**
   - Visit: https://www.raspberrypi.com/software/operating-systems/
   - Download "Raspberry Pi OS Lite" (64-bit)
   - Extract the .img file from the .zip

2. **Flash with balenaEtcher**
   - Install and launch balenaEtcher
   - Click "Flash from file" and select the .img file
   - Click "Select target" and choose your SD card
   - Click "Flash!" and wait for completion

3. **Enable SSH and WiFi Manually**

   After flashing, the SD card will have a "boot" partition. Access it:

   **Enable SSH:**
   ```bash
   # Create an empty file named 'ssh' in the boot partition
   # On Windows: Create a file called 'ssh' with no extension in the boot drive
   # On Mac/Linux:
   touch /Volumes/boot/ssh
   ```

   **Configure WiFi:**
   Create a file named `wpa_supplicant.conf` in the boot partition:

   ```conf
   country=US
   ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
   update_config=1

   network={
       ssid="YourNetworkName"
       psk="YourPassword"
       key_mgmt=WPA-PSK
   }
   ```

   Replace `US` with your country code, and update SSID and password.

## Initial Raspberry Pi Setup

### 1. Boot the Raspberry Pi

1. **Remove SD card from computer**
2. **Insert SD card into Raspberry Pi**
3. **Attach hardware:**
   - Mount HiFiBerry DAC+ ADC Pro on GPIO pins
   - Plug in USB Bluetooth adapter
   - Connect power supply
4. **Wait for boot** (2-3 minutes for first boot)

### 2. Find Raspberry Pi IP Address

**Option A: Using hostname (if configured)**
```bash
ping audioreceiver.local
# Or
ping raspberrypi.local
```

**Option B: Check your router**
- Log into your router's admin panel
- Look for "audioreceiver" or "raspberrypi" in connected devices

**Option C: Network scan**
```bash
# On Linux/Mac
nmap -sn 192.168.1.0/24

# On Windows, use Advanced IP Scanner
# Download from: https://www.advanced-ip-scanner.com/
```

### 3. Connect via SSH

```bash
# Replace with your Raspberry Pi's IP address or hostname
ssh pi@audioreceiver.local
# Or
ssh pi@192.168.1.xxx

# Enter the password you set during imaging
```

**First-time connection:** You'll see a security warning. Type `yes` to continue.

### 4. Update System (Optional but Recommended)

```bash
# Update package lists
sudo apt-get update

# Upgrade installed packages (this takes 5-10 minutes)
sudo apt-get upgrade -y
```

### 5. Configure Raspberry Pi

```bash
# Optional: Run configuration tool
sudo raspi-config
```

Useful settings:
- System Options → Password (change if needed)
- System Options → Hostname (change if needed)
- Localization Options → Timezone
- Localization Options → WLAN Country

**Exit and save when done**

## Install Audio Receiver

Now you're ready to install the audio receiver software!

### 1. Clone Repository

```bash
cd ~
git clone https://github.com/derkardamon/audio-receiver.git
cd audio-receiver
```

### 2. Make Scripts Executable

```bash
chmod +x install.sh uninstall.sh
chmod +x scripts/*.sh
```

### 3. Run Installation

```bash
sudo ./install.sh
```

This will:
- Install all required packages (BlueZ, PipeWire, WirePlumber)
- Configure HiFiBerry DAC
- Set up Bluetooth auto-pairing
- Configure audio routing
- Enable all services

**Installation takes 10-15 minutes.**

### 4. Reboot

```bash
sudo reboot
```

Your SSH connection will close. Wait 1-2 minutes for the reboot.

### 5. Reconnect

```bash
ssh pi@audioreceiver.local
```

## Verification

### 1. Run Status Check

```bash
cd ~/audio-receiver
./scripts/check-status.sh
```

You should see all services running with green checkmarks:
- ✓ Bluetooth service
- ✓ Auto-pair service
- ✓ PipeWire service
- ✓ WirePlumber service
- ✓ HiFiBerry detected
- ✓ Bluetooth adapter detected

### 2. Check HiFiBerry

```bash
aplay -l
```

You should see:
```
card 0: sndrpihifiberry [snd_rpi_hifiberry_dacplusadcpro]
```

### 3. Check Bluetooth Adapter

```bash
hciconfig
```

You should see:
```
hci0:   Type: Primary  Bus: USB
        BD Address: XX:XX:XX:XX:XX:XX  ACL MTU: 1021:8  SCO MTU: 64:1
        UP RUNNING
```

### 4. Test Bluetooth Connection

**On your phone/tablet:**
1. Open Bluetooth settings
2. Look for "RaspberryPi-Audio" (or your hostname)
3. Tap to connect
4. No PIN required (auto-pair)
5. Play music

### 5. Verify Audio Output

The audio should play through the HiFiBerry's outputs automatically.

**Test with speaker test (optional):**
```bash
speaker-test -c2 -t wav
```

Press Ctrl+C to stop.

## Troubleshooting Fresh Installation

### SD Card Not Recognized

- Try a different SD card
- Ensure SD card is at least 8GB (16GB recommended)
- Reformat SD card and try again

### Cannot SSH to Raspberry Pi

```bash
# Check if SSH file was created
# On boot partition, there should be a file named 'ssh'

# Verify WiFi configuration
# Check wpa_supplicant.conf file on boot partition

# Try connecting via Ethernet cable instead
```

### HiFiBerry Not Detected

```bash
# Check if HiFiBerry is properly seated on GPIO pins
# Verify /boot/config.txt has the overlay
cat /boot/config.txt | grep hifiberry

# Should show:
# dtoverlay=hifiberry-dacplusadcpro
```

### Bluetooth Adapter Not Detected

```bash
# Check if USB adapter is plugged in
lsusb

# You should see your Bluetooth adapter listed
```

### Installation Script Fails

```bash
# Check internet connection
ping -c 4 google.com

# Try updating package lists manually
sudo apt-get update

# Run installation again
cd ~/audio-receiver
sudo ./install.sh
```

### Audio Routing to Wrong Device

```bash
# Run the PipeWire fix script
sudo ./scripts/fix-pipewire.sh

# Reboot
sudo reboot
```

## Post-Installation Customization

### Change Bluetooth Device Name

```bash
sudo nano /etc/bluetooth/main.conf

# Find this line:
# Name = RaspberryPi-Audio

# Change to your preferred name:
# Name = MyAudioReceiver

# Save and restart Bluetooth
sudo systemctl restart bluetooth
```

### Adjust Audio Quality

See [AUDIO_ROUTING.md](AUDIO_ROUTING.md) for detailed configuration.

## Next Steps

- Review [README.md](README.md) for full documentation
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
- Read [AUDIO_ROUTING.md](AUDIO_ROUTING.md) for audio configuration
- Explore helper scripts in `scripts/` directory

## Common Commands Reference

```bash
# Check status
./scripts/check-status.sh

# Restart Bluetooth
sudo systemctl restart bluetooth

# Restart audio services
systemctl --user restart pipewire wireplumber

# View logs
journalctl -u bluetooth -f
journalctl -u bluetooth-autopair -f
journalctl --user -u wireplumber -f

# List paired devices
bluetoothctl devices

# Remove all paired devices
./scripts/unpair-all.sh

# Test audio
speaker-test -c2 -t wav

# Check audio devices
aplay -l
pactl list sinks short
```

## Support

If you encounter issues:

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review logs with `./scripts/check-status.sh`
3. Open an issue: https://github.com/derkardamon/audio-receiver/issues

## Summary Checklist

- [ ] Backed up important data
- [ ] Flashed Raspberry Pi OS Lite to SD card
- [ ] Configured SSH and WiFi
- [ ] Booted Raspberry Pi with HiFiBerry and Bluetooth adapter attached
- [ ] Connected via SSH
- [ ] Updated system (optional)
- [ ] Cloned audio-receiver repository
- [ ] Ran install.sh script
- [ ] Rebooted
- [ ] Verified all services running
- [ ] Successfully connected phone/tablet
- [ ] Confirmed audio plays through HiFiBerry

---

**Repository**: https://github.com/derkardamon/audio-receiver

**Last Updated**: 2026-02-21
