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
git clone https://github.com/derkardamon/rpi-audio-receiver.git
cd rpi-audio-receiver
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

### Check Bluetooth Status

```bash
systemctl status bluetooth
systemctl status bluetooth-autopair
```

### Check Audio Devices

```bash
aplay -l
```

### Check PipeWire Status

```bash
systemctl --user status pipewire
systemctl --user status pipewire-pulse
systemctl --user status wireplumber
```

### View Bluetooth Devices

```bash
bluetoothctl devices
```

### Check Bluetooth Logs

```bash
journalctl -u bluetooth -f
```

### Reset Bluetooth

```bash
sudo systemctl restart bluetooth
sudo systemctl restart bluetooth-autopair
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

## Project Structure

```
.
├── configs/
│   ├── bluetooth/
│   │   └── main.conf           # BlueZ configuration
│   └── pipewire/
│       ├── pipewire.conf       # PipeWire main configuration
│       └── pipewire-pulse.conf # PulseAudio compatibility
├── scripts/
│   └── bluetooth-autopair      # Auto-pairing script
├── services/
│   └── bluetooth-autopair.service  # Systemd service
├── install.sh                  # Main installation script
└── README.md                   # This file
```

## License

MIT License

## Credits

Based on the original work by:
- https://github.com/nicokaiser/rpi-audio-receiver

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
