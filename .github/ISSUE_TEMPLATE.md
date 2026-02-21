---
name: Bug Report or Support Request
about: Report an issue or ask for help
---

## System Information

- Raspberry Pi Model:
- OS Version: (run `cat /etc/os-release`)
- HiFiBerry Model:
- Bluetooth Adapter Model:

## Description

<!-- Describe the issue you're experiencing -->

## Steps to Reproduce

1.
2.
3.

## Expected Behavior

<!-- What should happen? -->

## Actual Behavior

<!-- What actually happens? -->

## Logs

Please include relevant logs:

```bash
# Bluetooth status
systemctl status bluetooth

# Auto-pair service status
systemctl status bluetooth-autopair

# PipeWire status
systemctl --user status pipewire wireplumber

# Recent logs
journalctl -u bluetooth -n 50
journalctl --user -u wireplumber -n 50

# Audio devices
aplay -l
pactl list sinks short
```

## Additional Information

<!-- Any other relevant information -->
