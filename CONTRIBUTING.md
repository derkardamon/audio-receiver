# Contributing to Raspberry Pi Audio Receiver

Thank you for your interest in contributing to this project! This document provides guidelines for contributing.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:

1. **Clear description** of the problem
2. **Steps to reproduce** the issue
3. **Expected behavior** vs actual behavior
4. **System information:**
   - Raspberry Pi model
   - Raspberry Pi OS version
   - HiFiBerry model
   - Bluetooth adapter model
5. **Logs** from diagnostic commands:
   ```bash
   ./scripts/check-status.sh
   journalctl -u bluetooth -n 50
   journalctl -u bluetooth-autopair -n 50
   ```

### Suggesting Enhancements

For feature requests or enhancements:

1. **Check existing issues** to avoid duplicates
2. **Describe the feature** and its benefits
3. **Provide use cases** where this would be helpful
4. **Consider compatibility** with various hardware configurations

### Pull Requests

We welcome pull requests! Here's the process:

1. **Fork the repository**
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following our coding standards
4. **Test thoroughly** on actual hardware
5. **Commit with clear messages**:
   ```bash
   git commit -m "Add feature: description of what it does"
   ```
6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a pull request** with:
   - Clear description of changes
   - Why the change is needed
   - Testing you've performed
   - Any breaking changes

## Development Guidelines

### Code Style

- Use clear, descriptive variable names
- Comment complex logic
- Keep scripts modular and reusable
- Follow bash scripting best practices:
  - Use `set -e` for error handling
  - Quote variables: `"$variable"`
  - Check for required tools/files
  - Provide helpful error messages

### Configuration Files

- Keep configuration well-commented
- Provide sensible defaults
- Document all options
- Consider different hardware configurations

### Documentation

- Update README.md for major changes
- Update TROUBLESHOOTING.md for known issues
- Keep QUICKSTART.md simple and beginner-friendly
- Add inline comments to complex configurations

### Testing

Before submitting changes, test on:

- Fresh Raspberry Pi OS Lite installation
- With HiFiBerry DAC+ ADC Pro
- With USB Bluetooth adapter
- Connection from Android device
- Connection from iOS device
- Multiple device pairing
- Audio quality at different bitrates
- Volume control from devices

### Commit Messages

Use clear, descriptive commit messages:

```
Good:
- "Add support for HiFiBerry DAC2 HD"
- "Fix auto-pairing timeout issue"
- "Improve PipeWire buffer configuration"

Bad:
- "Fix bug"
- "Update config"
- "Changes"
```

## Project Structure

```
.
├── configs/              # Configuration files
│   ├── bluetooth/       # BlueZ configurations
│   └── pipewire/        # PipeWire configurations
├── scripts/             # Helper scripts
├── services/            # Systemd service files
├── install.sh           # Main installation script
├── uninstall.sh         # Uninstallation script
└── docs/                # Documentation
```

## Areas for Contribution

We especially welcome contributions in these areas:

### Features

- Support for additional DAC/sound cards
- Web-based configuration interface
- Multi-room audio support
- AirPlay support
- Spotify Connect integration
- Display integration for track info
- Volume normalization
- Equalizer support

### Improvements

- Better error handling
- More robust auto-reconnection
- Improved audio quality presets
- Battery monitoring (for portable setups)
- LED status indicators
- Button controls

### Documentation

- Video tutorials
- More detailed troubleshooting
- Hardware compatibility list
- Performance benchmarks
- Localization (translations)

### Testing

- Automated testing scripts
- Compatibility testing with different hardware
- Stress testing with rapid connections/disconnections
- Audio quality measurements

## Hardware Compatibility

If you test with different hardware:

1. Document your setup in detail
2. Report success or issues
3. Provide any necessary configuration changes
4. Consider contributing hardware-specific guides

### Tested Hardware

Please update this list if you successfully test new hardware:

**Raspberry Pi Models:**
- Raspberry Pi 4 Model B (tested)
- Raspberry Pi 3 Model B+ (untested)
- Raspberry Pi 5 (untested)

**DACs:**
- HiFiBerry DAC+ ADC Pro (tested)
- HiFiBerry DAC2 HD (untested)
- Other HiFiBerry models (untested)

**Bluetooth Adapters:**
- Asus USB-BT500 (tested)
- TP-Link UB400 (untested)
- Other USB Bluetooth 5.0+ adapters (untested)

## Code of Conduct

### Our Pledge

We are committed to providing a friendly, safe, and welcoming environment for all contributors.

### Expected Behavior

- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment of any kind
- Discriminatory language or actions
- Trolling or insulting comments
- Publishing private information
- Other unprofessional conduct

## Questions?

- Open a discussion on GitHub
- Check existing issues and pull requests
- Read the documentation thoroughly

## Recognition

Contributors will be:
- Listed in the project README
- Credited in release notes
- Acknowledged in commit history

Thank you for helping make this project better!
