# Quick Start Guide

This guide will help you quickly set up your Raspberry Pi as a Bluetooth audio receiver.

## Prerequisites

- Raspberry Pi 4 Model B with Raspberry Pi OS Lite installed
- HiFiBerry DAC+ ADC Pro mounted on GPIO pins
- Asus USB-BT500 Bluetooth adapter plugged in
- Internet connection
- SSH access or direct terminal access

## Installation Steps

### 1. Clone the Repository

```bash
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

This will take several minutes. The script will:
- Update your system
- Install all required packages
- Configure Bluetooth and audio
- Set up auto-pairing
- Enable all services

### 4. Reboot

```bash
sudo reboot
```

### 5. Test Connection

After reboot:

1. Open Bluetooth settings on your phone/tablet
2. Look for "RaspberryPi-Audio"
3. Tap to connect (no pairing code needed)
4. Play music from your device

## Verification

Run the status check script:

```bash
cd audio-receiver
chmod +x scripts/check-status.sh
./scripts/check-status.sh
```

You should see all services running with checkmarks.

## Common Issues

### Device Not Showing Up

```bash
sudo systemctl restart bluetooth
sudo systemctl restart bluetooth-autopair
```

### No Audio Output

Check if HiFiBerry is detected:
```bash
aplay -l
```

You should see "HiFiBerry" in the list.

### USB Bluetooth Not Working

Check if adapter is recognized:
```bash
hciconfig
```

If you see `hci0`, the adapter is working.

## Next Steps

- Read the full [README.md](README.md) for detailed configuration
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more help
- Customize device name in `/etc/bluetooth/main.conf`

## Quick Commands

| Command | Description |
|---------|-------------|
| `./scripts/check-status.sh` | Check system status |
| `./scripts/unpair-all.sh` | Remove all paired devices |
| `sudo systemctl restart bluetooth` | Restart Bluetooth |
| `bluetoothctl devices` | List paired devices |

## Getting Help

If you encounter issues:

1. Check the logs: `journalctl -u bluetooth -f`
2. Run status check: `./scripts/check-status.sh`
3. Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
4. Open an issue on GitHub
