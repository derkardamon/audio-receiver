# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2026-02-21

### Breaking Changes
- **Removed WirePlumber Lua configuration files** - Modern WirePlumber 0.5+ no longer supports Lua configs
  - Removed `configs/wireplumber/bluetooth.lua.d/`
  - Removed `configs/wireplumber/main.lua.d/`
  - Installation script no longer copies WirePlumber configs
  - See `WIREPLUMBER_MODERNIZATION.md` for details

### Added
- **New Documentation**
  - `WIREPLUMBER_MODERNIZATION.md` - Explains WirePlumber configuration changes
  - `MIGRATION_GUIDE.md` - Step-by-step migration from older versions
  - `CHANGELOG.md` - This file
- **New Scripts**
  - `scripts/check-audio.sh` - Comprehensive audio system diagnostics

### Changed
- **Installation Process**
  - No longer creates `/etc/wireplumber/` directories
  - Relies on default WirePlumber configuration (better for compatibility)
  - Simplified installation with fewer config files to manage

- **Documentation Updates**
  - Updated `README.md` with PipeWire tool usage (`wpctl` instead of `pactl`)
  - Updated `TROUBLESHOOTING.md` with modern WirePlumber troubleshooting
  - Replaced all references to `pactl` with `wpctl` commands
  - Added section explaining PipeWire vs PulseAudio tools

- **Uninstall Process**
  - Updated `uninstall.sh` to remove old WirePlumber configs if present
  - Added cleanup of PipeWire config files

### Fixed
- Eliminated "Old configuration file detected" warnings in WirePlumber logs
- Removed `pactl` command errors (not needed with PipeWire)

### Migration Notes
If you installed this project before February 2026:
1. Pull the latest code: `git pull`
2. Remove old WirePlumber configs: `sudo rm -rf /etc/wireplumber/{bluetooth,main}.lua.d`
3. Restart WirePlumber: `systemctl --user restart wireplumber`
4. See `MIGRATION_GUIDE.md` for complete instructions

### Technical Details
Modern WirePlumber 0.5.0+ includes excellent defaults for:
- Bluetooth audio codec selection (LDAC, aptX HD, aptX, AAC, SBC)
- Hardware audio device detection and configuration
- Automatic profile selection for Bluetooth devices
- Audio routing and source switching

Custom configuration is no longer needed for basic Bluetooth audio receiver functionality.

## [1.x] - Prior to 2026-02-21

Initial versions with Lua-based WirePlumber configuration.
