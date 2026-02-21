# Raspberry Pi Audio Receiver / Streambox

High-quality Bluetooth audio receiver using Raspberry Pi 4B with HiFiBerry DAC+ ADC Pro and external USB Bluetooth adapter.

## Features

- **High-quality audio** with HiFiBerry DAC+ ADC Pro
- **Bluetooth audio streaming** via BlueZ/PipeWire
- **Auto-pairing** without verification for all devices (Android & iOS)
- **Multi-device support** - multiple devices can be paired, one active stream at a time
- **Volume control** from all connected clients
- **Optimized for audio quality** with PipeWire configuration

## Hardware Requirements

- Raspberry Pi 4 Model B
- HiFiBerry DAC+ ADC Pro
- Asus USB-BT500 Bluetooth Smart Ready USB Adapter (or compatible)
- MicroSD card (16GB or larger)
- Power supply for Raspberry Pi

## Software Requirements

- Raspberry Pi OS Lite (latest version)

## Installation

### 1. Prepare Raspberry Pi OS Lite

Download and install Raspberry Pi OS Lite on your microSD card using Raspberry Pi Imager.

### 2. Initial Setup

Boot your Raspberry Pi and complete initial setup:
- Set hostname, password
- Configure network (WiFi or Ethernet)
- Enable SSH if needed

### 3. Clone Repository

```bash
git clone https://github.com/derkardamon/audio-receiver.git
cd audio-receiver
```

### 4. Run Installation Script

```bash
sudo chmod +x install.sh
sudo ./install.sh
```

The installation script will:
- Update system packages
- Install BlueZ, PipeWire, and required dependencies
- Disable internal Bluetooth
- Configure HiFiBerry DAC+ ADC Pro
- Set up Bluetooth auto-pairing
- Configure PipeWire for optimal audio quality
- Enable all necessary services

### 5. Reboot

```bash
sudo reboot
```

## Usage

### Connecting Devices

1. On your smartphone or tablet, open Bluetooth settings
2. Look for device named "RaspberryPi-Audio"
3. Connect to the device
4. No pairing code required - connection is automatic
5. Start playing audio on your device

### Multiple Devices

- Multiple devices can be paired simultaneously
- Only one device can stream audio at a time
- When a new device connects and starts streaming, the previous connection will be disconnected
- All previously paired devices remain trusted for easy reconnection

### Volume Control

Volume can be controlled from:
- The connected device (phone/tablet)
- System volume controls on the device
- AVRCP protocol allows full volume synchronization

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions.

Quick diagnostic commands:
- `./scripts/check-status.sh` - Check all services
- `./scripts/check-audio.sh` - Check audio system
- `wpctl status` - Show PipeWire devices

**Note:** This project uses PipeWire, not PulseAudio. Use `wpctl` commands instead of `pactl`.

## Configuration

### Bluetooth Settings

Edit `/etc/bluetooth/main.conf` to customize:
- Device name (visible to other devices)
- Discoverability settings
- Pairing behavior

### Audio Quality Settings

Edit `/etc/pipewire/pipewire.conf` to adjust:
- Sample rates (default: 48kHz, supports up to 192kHz)
- Buffer sizes (default: 1024 samples)
- Real-time priority settings

### HiFiBerry Configuration

The HiFiBerry DAC+ ADC Pro is configured in `/boot/config.txt`:
```
dtoverlay=hifiberry-dacplusadcpro
dtoverlay=disable-bt
```

## Troubleshooting

For comprehensive troubleshooting, see:
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Complete troubleshooting guide
- **[AUDIO_ROUTING.md](AUDIO_ROUTING.md)** - Audio routing and configuration guide

### Quick Fixes

**HiFiBerry not Card 0, audio routing issues, or PipeWire not working:**
```bash
cd ~/audio-receiver
sudo ./scripts/fix-all.sh
```

**Individual fixes:**
- Card ordering only: `sudo ./scripts/fix-card-order.sh`
- PipeWire only: `sudo ./scripts/fix-pipewire.sh`

### Quick Status Checks

```bash
# Check all services
./scripts/check-status.sh

# Verify installation
./scripts/verify-installation.sh

# Check Bluetooth status
systemctl status bluetooth
systemctl status bluetooth-autopair

# Check PipeWire status
systemctl --user status pipewire wireplumber

# Check audio devices
aplay -l

# Test audio output
speaker-test -c2 -t wav
```

## Bluetooth Behavior with Multiple Clients

### Pairing vs. Connection

- **Pairing**: Device is recognized and trusted (stored permanently)
- **Connection**: Active audio streaming session

### BlueZ Behavior

- Multiple devices can be paired at the same time
- Only one active A2DP sink stream per time
- When Device A is streaming and Device B connects:
  - Device A connection is terminated
  - Device B takes over audio streaming

### PipeWire Behavior

- Each connected device creates a `bluez_sink`
- Only one sink can receive audio at a time
- Previous sinks remain but become inactive
- Automatic switching when new device connects

## Audio Quality Optimization

The system is configured for:
- 48kHz default sample rate (supports 44.1-192kHz)
- 1024 sample buffer for low latency
- Real-time scheduling priority for audio
- High-quality resampling (quality level 10)
- Minimal audio processing overhead

## Advanced Configuration

### Changing Device Name

Edit `/etc/bluetooth/main.conf`:
```
[General]
Name = YourCustomName
```

Then restart Bluetooth:
```bash
sudo systemctl restart bluetooth
```

### Adjusting Audio Buffer Size

Edit `/etc/pipewire/pipewire.conf`:
```
default.clock.quantum = 1024  # Change to 512 for lower latency or 2048 for more stability
```

## Documentation

### Setup & Installation
- **[README.md](README.md)** - Main documentation (this file)
- **[FRESH_INSTALL.md](FRESH_INSTALL.md)** - Complete guide to wipe SD card and install from scratch
- **[QUICKSTART.md](QUICKSTART.md)** - Quick setup guide
- **[HARDWARE.md](HARDWARE.md)** - Hardware compatibility guide
- **[RPI_SETUP.md](RPI_SETUP.md)** - Raspberry Pi setup guide

### Troubleshooting & Configuration
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Comprehensive troubleshooting
- **[AUDIO_ROUTING.md](AUDIO_ROUTING.md)** - Audio configuration and routing
- **[WIREPLUMBER_MODERNIZATION.md](WIREPLUMBER_MODERNIZATION.md)** - WirePlumber configuration update explained
- **[MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)** - Migrating from older versions

### Contributing
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contributing guidelines

## Project Structure

```
.
├── configs/
│   ├── alsa/
│   │   └── alsa-base.conf               # Sound card ordering
│   ├── bluetooth/
│   │   └── main.conf                    # BlueZ configuration
│   └── pipewire/
│       ├── pipewire.conf                # PipeWire main config
│       └── pipewire-pulse.conf          # PulseAudio compatibility
├── scripts/
│   ├── bluetooth-autopair               # Auto-pairing daemon
│   ├── check-status.sh                  # System status checker
│   ├── check-audio.sh                   # Audio system checker
│   ├── fix-all.sh                       # Complete audio fix (recommended)
│   ├── fix-card-order.sh                # Fix sound card ordering
│   ├── fix-pipewire.sh                  # PipeWire fix script
│   ├── unpair-all.sh                    # Remove all pairings
│   ├── update-config.sh                 # Config updater
│   └── verify-installation.sh           # Installation verifier
├── services/
│   └── bluetooth-autopair.service       # Systemd service
├── install.sh                           # Main installer
├── uninstall.sh                         # Uninstaller
└── *.md                                 # Documentation files
```

## License

MIT License

## Repository

**GitHub**: https://github.com/derkardamon/audio-receiver

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly on actual hardware
5. Submit a pull request

For bug reports or feature requests, please open an issue on GitHub.

## Credits

Based on the original work by [nicokaiser/rpi-audio-receiver](https://github.com/nicokaiser/rpi-audio-receiver)
