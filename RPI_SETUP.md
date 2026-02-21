# Raspberry Pi Setup Guide

Complete instructions for getting the audio receiver running on your Raspberry Pi.

## Prerequisites

- Raspberry Pi 4B with Raspberry Pi OS (64-bit recommended)
- HiFiBerry DAC+ ADC Pro installed
- Asus USB-BT500 Bluetooth adapter
- SSH access to your Pi OR direct access with keyboard/monitor
- Internet connection on the Pi

## Method 1: Clone Directly on the Pi (Recommended)

### Step 1: Connect to Your Pi

```bash
# From your computer, SSH into the Pi
ssh pi@raspberrypi.local
# Or use the IP address
ssh pi@192.168.1.xxx
```

Default password is usually `raspberry` (change it after first login for security!)

### Step 2: Clone the Repository

```bash
# Navigate to home directory
cd ~

# Clone the repository
git clone https://github.com/derkardamon/audio-receiver.git

# Enter the directory
cd audio-receiver
```

### Step 3: Run Installation

```bash
# Make scripts executable
chmod +x install.sh
chmod +x scripts/*.sh

# Run the installer
sudo ./install.sh
```

The installer will:
- Install all dependencies (BlueZ, PipeWire, etc.)
- Configure Bluetooth for auto-pairing
- Set up audio routing
- Configure HiFiBerry DAC
- Install and start the systemd service
- Reboot the Pi when complete

### Step 4: After Reboot

```bash
# Check status
cd ~/audio-receiver
./scripts/check-status.sh

# Verify installation
./scripts/verify-installation.sh
```

## Method 2: Copy Files Manually (Alternative)

If you don't have git on the Pi or prefer manual copying:

### Step 1: Download on Your Computer

```bash
# On your computer
cd ~/Downloads
git clone https://github.com/derkardamon/audio-receiver.git
cd audio-receiver
```

### Step 2: Copy to Pi via SCP

```bash
# From your computer, copy entire directory
scp -r ~/Downloads/audio-receiver pi@raspberrypi.local:~/

# Or using IP address
scp -r ~/Downloads/audio-receiver pi@192.168.1.xxx:~/
```

### Step 3: SSH to Pi and Install

```bash
# SSH into the Pi
ssh pi@raspberrypi.local

# Navigate to the directory
cd ~/audio-receiver

# Make scripts executable
chmod +x install.sh
chmod +x scripts/*.sh

# Run installer
sudo ./install.sh
```

## Method 3: Direct Download (No Git Required)

### On the Raspberry Pi:

```bash
# Download the repository as a zip file
wget https://github.com/derkardamon/audio-receiver/archive/refs/heads/main.zip

# Install unzip if not available
sudo apt install unzip

# Extract the archive
unzip main.zip

# Rename directory
mv audio-receiver-main audio-receiver

# Enter directory
cd audio-receiver

# Make scripts executable
chmod +x install.sh
chmod +x scripts/*.sh

# Run installer
sudo ./install.sh
```

## Quick Start (TL;DR)

```bash
# SSH to Pi
ssh pi@raspberrypi.local

# Clone and install
git clone https://github.com/derkardamon/audio-receiver.git
cd audio-receiver
sudo ./install.sh

# Wait for reboot, then verify
./scripts/check-status.sh
```

## Post-Installation

### Test the Setup

1. **Check Bluetooth visibility:**
   ```bash
   bluetoothctl show
   # Look for: Discoverable: yes, Pairable: yes
   ```

2. **Check audio devices:**
   ```bash
   aplay -l
   # Should show HiFiBerry DAC
   ```

3. **Check service status:**
   ```bash
   systemctl status bluetooth-autopair
   ```

### Connect Your Device

1. On your phone/computer, go to Bluetooth settings
2. Look for "PiuPiu-Audio"
3. Connect (no PIN required)
4. Play audio - it should come through your speakers!

### Useful Commands

```bash
# View Bluetooth logs in real-time
sudo journalctl -u bluetooth-autopair -f

# Restart Bluetooth service
sudo systemctl restart bluetooth

# Unpair all devices
./scripts/unpair-all.sh

# Check what's connected
bluetoothctl info
```

## Troubleshooting

### Can't Find "PiuPiu-Audio"

```bash
# Check if Bluetooth is up
sudo systemctl status bluetooth

# Make adapter discoverable
bluetoothctl
[bluetooth]# discoverable on
[bluetooth]# pairable on
```

### No Audio Output

```bash
# Check HiFiBerry is detected
aplay -l

# Check PipeWire is running
systemctl --user status pipewire
systemctl --user status pipewire-pulse

# Test audio
speaker-test -c2 -t wav
```

### Permission Issues

```bash
# Make sure user is in audio group
sudo usermod -a -G audio $USER

# Reboot
sudo reboot
```

### See Full Troubleshooting Guide

```bash
cat TROUBLESHOOTING.md
```

## Network Setup Tips

### Find Your Pi's IP Address

On the Pi:
```bash
hostname -I
```

### Setup Static IP (Optional)

Edit dhcpcd.conf:
```bash
sudo nano /etc/dhcpcd.conf
```

Add:
```
interface wlan0
static ip_address=192.168.1.100/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 8.8.8.8
```

### Enable SSH (If Disabled)

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

## Security Recommendations

1. **Change default password:**
   ```bash
   passwd
   ```

2. **Update system:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. **Setup SSH keys** (instead of password):
   ```bash
   # On your computer, copy your public key
   ssh-copy-id pi@raspberrypi.local
   ```

4. **Disable password SSH** (after keys work):
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Set: PasswordAuthentication no
   sudo systemctl restart ssh
   ```

## Updating the Software

To get the latest updates from GitHub:

```bash
cd ~/audio-receiver
git pull origin main
sudo ./install.sh
```

## Uninstalling

If you need to remove everything:

```bash
cd ~/audio-receiver
sudo ./uninstall.sh
```

This will:
- Stop and remove services
- Restore original configs
- Remove installed packages
- Clean up all modifications

## Hardware Notes

- **HiFiBerry DAC+ ADC Pro** must be properly seated on GPIO pins
- **Asus USB-BT500** should be in a USB 2.0 port (better compatibility)
- Power supply should be 5V/3A minimum for Pi 4B
- Use quality USB cable for stable power

## Additional Resources

- **README.md** - Project overview and features
- **QUICKSTART.md** - Fast setup guide
- **HARDWARE.md** - Detailed hardware specifications
- **TROUBLESHOOTING.md** - Common issues and solutions
- **CONTRIBUTING.md** - How to contribute improvements

## Getting Help

If you encounter issues:

1. Check `./scripts/check-status.sh` output
2. Run `./scripts/verify-installation.sh`
3. Review logs: `sudo journalctl -u bluetooth-autopair -n 50`
4. Consult TROUBLESHOOTING.md
5. Open an issue on GitHub

## Success Checklist

- [ ] Pi boots without errors
- [ ] HiFiBerry DAC detected (`aplay -l`)
- [ ] Bluetooth adapter working (`hciconfig`)
- [ ] "PiuPiu-Audio" visible on devices
- [ ] Can connect without PIN
- [ ] Audio plays through speakers
- [ ] Volume control works from phone/computer

Enjoy your wireless audio receiver!
