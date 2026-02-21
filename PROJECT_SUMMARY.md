# Raspberry Pi Audio Receiver - Project Summary

## Overview

This project transforms a Raspberry Pi 4 into a high-quality Bluetooth audio receiver using a HiFiBerry DAC+ ADC Pro and external USB Bluetooth adapter. It provides seamless auto-pairing and professional audio quality.

## Repository

**GitHub**: https://github.com/derkardamon/audio-receiver

## Quick Links

- [Fresh Install Guide](FRESH_INSTALL.md) - Complete guide to wipe SD card and start fresh
- [Installation Guide](README.md) - Complete setup instructions
- [Quick Start](QUICKSTART.md) - Fast setup guide
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions
- [Audio Routing](AUDIO_ROUTING.md) - Audio configuration details
- [Hardware Guide](HARDWARE.md) - Hardware compatibility info
- [Contributing](CONTRIBUTING.md) - Contribution guidelines

## Project Structure

```
audio-receiver/
├── .github/
│   └── ISSUE_TEMPLATE.md         # GitHub issue template
├── configs/
│   ├── bluetooth/
│   │   └── main.conf             # BlueZ Bluetooth configuration
│   ├── pipewire/
│   │   ├── pipewire.conf         # PipeWire main configuration
│   │   └── pipewire-pulse.conf   # PulseAudio compatibility layer
│   └── wireplumber/
│       ├── bluetooth.lua.d/
│       │   └── 50-bluez-config.lua    # Legacy Bluetooth config
│       └── main.lua.d/
│           ├── 50-bluez-config.lua    # Modern Bluetooth config
│           └── 51-alsa-hifiberry.lua  # HiFiBerry routing
├── scripts/
│   ├── bluetooth-autopair        # Auto-pairing daemon
│   ├── check-status.sh          # System status checker
│   ├── fix-pipewire.sh          # PipeWire fix utility
│   ├── unpair-all.sh            # Remove all pairings
│   ├── update-config.sh         # Configuration updater
│   └── verify-installation.sh   # Installation verifier
├── services/
│   └── bluetooth-autopair.service    # Systemd service unit
├── install.sh                   # Main installation script
├── uninstall.sh                 # Uninstallation script
├── package.json                 # Project metadata
└── *.md                         # Documentation files
```

## Key Features

1. **Auto-Pairing**: Automatic pairing without PIN codes
2. **High-Quality Audio**: Professional DAC with optimized PipeWire configuration
3. **Multi-Device Support**: Multiple devices can be paired, one active at a time
4. **Volume Control**: Full volume control from connected devices
5. **Easy Installation**: Single-command installation script
6. **Robust Configuration**: Modern PipeWire/WirePlumber setup

## Technology Stack

- **OS**: Raspberry Pi OS Lite
- **Bluetooth Stack**: BlueZ 5.x
- **Audio Server**: PipeWire 0.3+
- **Session Manager**: WirePlumber
- **DAC**: HiFiBerry DAC+ ADC Pro
- **Bluetooth**: External USB Bluetooth 5.0 adapter

## Installation Summary

```bash
# Clone repository
git clone https://github.com/derkardamon/audio-receiver.git
cd audio-receiver

# Run installation
sudo ./install.sh

# Reboot
sudo reboot
```

## Maintenance Scripts

| Script | Purpose |
|--------|---------|
| `scripts/check-status.sh` | Check all service statuses |
| `scripts/fix-pipewire.sh` | Fix PipeWire configuration issues |
| `scripts/verify-installation.sh` | Verify installation completeness |
| `scripts/unpair-all.sh` | Remove all paired devices |
| `scripts/update-config.sh` | Update configuration files |

## Documentation Files

| File | Description |
|------|-------------|
| `README.md` | Main documentation and setup guide |
| `FRESH_INSTALL.md` | Complete guide to wipe SD card and fresh install |
| `QUICKSTART.md` | Quick setup instructions |
| `TROUBLESHOOTING.md` | Comprehensive troubleshooting guide |
| `AUDIO_ROUTING.md` | Audio routing and configuration details |
| `HARDWARE.md` | Hardware requirements and compatibility |
| `RPI_SETUP.md` | Raspberry Pi initial setup guide |
| `CONTRIBUTING.md` | Contribution guidelines |
| `PROJECT_SUMMARY.md` | Project overview and structure |
| `LICENSE` | MIT License |

## Configuration Files

### Bluetooth (`configs/bluetooth/`)
- `main.conf` - BlueZ configuration with auto-pairing settings

### PipeWire (`configs/pipewire/`)
- `pipewire.conf` - Audio server configuration (sample rates, buffers)
- `pipewire-pulse.conf` - PulseAudio compatibility layer

### WirePlumber (`configs/wireplumber/`)
- `bluetooth.lua.d/50-bluez-config.lua` - Legacy Bluetooth audio config
- `main.lua.d/50-bluez-config.lua` - Modern Bluetooth audio config
- `main.lua.d/51-alsa-hifiberry.lua` - HiFiBerry priority routing

## System Services

1. **bluetooth.service** - BlueZ Bluetooth daemon
2. **bluetooth-autopair.service** - Auto-pairing daemon
3. **pipewire.service** - Audio server (user service)
4. **pipewire-pulse.service** - PulseAudio compatibility (user service)
5. **wireplumber.service** - Session manager (user service)

## Common Tasks

### Check System Status
```bash
./scripts/check-status.sh
```

### Fix Audio Issues
```bash
sudo ./scripts/fix-pipewire.sh
```

### View Logs
```bash
# Bluetooth logs
journalctl -u bluetooth -f

# Auto-pair logs
journalctl -u bluetooth-autopair -f

# PipeWire logs
journalctl --user -u pipewire -f
journalctl --user -u wireplumber -f
```

### Test Audio
```bash
# List audio devices
aplay -l

# Test speaker output
speaker-test -c2 -t wav

# Check PipeWire sinks
pactl list sinks short
```

## Troubleshooting Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| Audio to HDMI instead of HiFiBerry | `sudo ./scripts/fix-pipewire.sh` |
| PipeWire "old config" warnings | `sudo ./scripts/fix-pipewire.sh` |
| Device won't pair | `sudo systemctl restart bluetooth-autopair` |
| No Bluetooth adapter | Check `hciconfig` output |
| Service failures | `./scripts/check-status.sh` |

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - See [LICENSE](LICENSE) file

## Credits

Based on [nicokaiser/rpi-audio-receiver](https://github.com/nicokaiser/rpi-audio-receiver)

## Support

- Issues: https://github.com/derkardamon/audio-receiver/issues
- Discussions: https://github.com/derkardamon/audio-receiver/discussions

## Version

Current Version: 1.0.0

Last Updated: 2026-02-21
