# Hardware Compatibility Guide

This document provides information about hardware compatibility and requirements for the Raspberry Pi Audio Receiver.

## Tested Configurations

### Working Configuration

- **Raspberry Pi:** Raspberry Pi 4 Model B
- **DAC:** HiFiBerry DAC+ ADC Pro
- **Bluetooth Adapter:** Asus USB-BT500 Bluetooth 5.0
- **OS:** Raspberry Pi OS Lite (latest)
- **Status:** ✓ Fully tested and working

## Raspberry Pi Models

### Recommended

| Model | RAM | Status | Notes |
|-------|-----|--------|-------|
| Raspberry Pi 4B | 2GB+ | ✓ Tested | Best performance |
| Raspberry Pi 5 | 4GB+ | Untested | Should work, may need config tweaks |

### Compatible (Likely)

| Model | RAM | Status | Notes |
|-------|-----|--------|-------|
| Raspberry Pi 3B+ | 1GB | Untested | May work with reduced buffer sizes |
| Raspberry Pi 400 | 4GB | Untested | Should work like Pi 4B |

### Not Recommended

| Model | RAM | Status | Notes |
|-------|-----|--------|-------|
| Raspberry Pi Zero | 512MB | Not recommended | Insufficient CPU power |
| Raspberry Pi 2 | 1GB | Not recommended | Older Bluetooth support |

## Audio DACs

### HiFiBerry Models

| Model | Status | Configuration |
|-------|--------|---------------|
| DAC+ ADC Pro | ✓ Tested | `dtoverlay=hifiberry-dacplusadcpro` |
| DAC2 HD | Untested | `dtoverlay=hifiberry-dac2hd` |
| DAC+ Pro | Untested | `dtoverlay=hifiberry-dacplus` |
| DAC+ Standard | Untested | `dtoverlay=hifiberry-dac` |
| Amp2 | Untested | `dtoverlay=hifiberry-amp` |

### Other DAC Manufacturers

| Brand | Model | Status | Notes |
|-------|-------|--------|-------|
| IQaudIO | DAC+ | Untested | May require different overlay |
| JustBoom | DAC HAT | Untested | May require different overlay |
| Pimoroni | Audio DAC SHIM | Untested | I2S based, should work |
| Generic | USB DAC | Should work | No special configuration needed |

### Configuration for Other DACs

For HiFiBerry alternatives, edit `/boot/config.txt` and replace:
```
dtoverlay=hifiberry-dacplusadcpro
```

With the appropriate overlay for your DAC. Common overlays:
- `dtoverlay=iqaudio-dacplus`
- `dtoverlay=justboom-dac`
- `dtoverlay=i2s-dac`

List all available overlays:
```bash
ls /boot/overlays/*dac*.dtbo
```

## Bluetooth Adapters

### USB Bluetooth 5.0+ (Recommended)

| Model | Chipset | Status | Notes |
|-------|---------|--------|-------|
| Asus USB-BT500 | Realtek RTL8761B | ✓ Tested | Excellent range and stability |
| TP-Link UB500 | Realtek RTL8761B | Untested | Same chipset as Asus |
| TP-Link UB400 | CSR8510 | Untested | Bluetooth 4.0, should work |
| Plugable USB-BT4LE | Broadcom BCM20702 | Untested | Good Linux support |

### Built-in Bluetooth (Not Recommended)

| Model | Built-in BT | Status | Notes |
|-------|-------------|--------|-------|
| Pi 4B | Bluetooth 5.0 | Not recommended | Disabled by design for better performance |
| Pi 3B+ | Bluetooth 4.2 | Not recommended | Shares antenna with WiFi |

**Why disable internal Bluetooth?**
- Better range and stability with external adapter
- No WiFi/Bluetooth interference
- Higher quality audio codec support
- More reliable auto-pairing

## Power Requirements

### Recommended Power Supplies

| Model | Voltage | Current | Notes |
|-------|---------|---------|-------|
| Official RPi PSU | 5V | 3A | Best compatibility |
| Quality USB-C | 5V | 3A+ | Must support 3A minimum |

### Power Considerations

- **HiFiBerry DAC+ ADC Pro:** Draws additional power
- **USB Bluetooth Adapter:** Adds ~100mA
- **Total recommended:** 5V 3A minimum
- **Underpowering symptoms:** Audio dropouts, random reboots, USB issues

Use quality power supplies with sufficient current rating!

## Storage Requirements

| Component | Space Required |
|-----------|---------------|
| Raspberry Pi OS Lite | ~2GB |
| Software packages | ~500MB |
| Free space for logs | ~500MB |
| **Total minimum** | ~3GB |
| **Recommended** | 16GB+ SD card |

### SD Card Recommendations

- **Class 10 or better**
- **A1 or A2 rating** for better performance
- **Reputable brands:** SanDisk, Samsung, Kingston
- Avoid cheap/no-name brands (reliability issues)

## Network Requirements

### WiFi

- **2.4GHz:** Good range, may interfere with Bluetooth
- **5GHz:** Better for avoiding Bluetooth interference
- **Ethernet:** Best option (no wireless interference)

### Bluetooth + WiFi Coexistence

If using both:
1. Use 5GHz WiFi when possible
2. Keep Bluetooth and WiFi on different frequencies
3. Use external USB Bluetooth adapter
4. Consider using Ethernet instead of WiFi

## Enclosures and Cooling

### Thermal Considerations

| Component | Heat Output | Cooling Needed |
|-----------|-------------|----------------|
| Raspberry Pi 4B | Moderate | Recommended |
| HiFiBerry DAC | Low | No |
| USB Bluetooth | Minimal | No |

### Cooling Options

1. **Passive:** Small heatsinks on SoC and RAM
2. **Active:** Small 5V fan (quiet operation recommended)
3. **Case:** Ventilated case or one with built-in heatsinks

### Recommended Enclosures

- Official Raspberry Pi 4 case (with fan)
- Flirc aluminum case (passive cooling)
- Any case with GPIO access for HiFiBerry

## Audio Output Options

### Analog Output (HiFiBerry)

- **3.5mm jack:** Line-level output
- **RCA connectors:** Professional audio equipment
- **Quality:** High-fidelity, low noise

### Digital Output Options

Some HiFiBerry models also support:
- **SPDIF:** Optical/coaxial digital out
- **I2S:** Direct digital connection

### Connection Examples

```
Raspberry Pi + HiFiBerry → RCA cables → Amplifier → Speakers
Raspberry Pi + HiFiBerry → 3.5mm cable → Active speakers
Raspberry Pi + HiFiBerry → SPDIF → AV Receiver → Speakers
```

## Bluetooth Audio Codecs

### Supported Codecs (in preference order)

1. **LDAC** - Sony's high-quality codec (990 kbps)
   - Requires: Android 8.0+ with LDAC support
   - Quality: Excellent

2. **aptX HD** - Qualcomm's high-res codec (576 kbps)
   - Requires: Device with aptX HD support
   - Quality: Very good

3. **aptX** - Qualcomm standard codec (352 kbps)
   - Requires: Device with aptX support
   - Quality: Good

4. **AAC** - Advanced Audio Coding (256 kbps)
   - Requires: iOS devices, some Android
   - Quality: Good

5. **SBC XQ** - Extended quality SBC
   - Requires: BlueZ 5.50+
   - Quality: Decent

6. **SBC** - Standard Bluetooth codec (328 kbps)
   - Universal compatibility
   - Quality: Acceptable

### Codec Selection

The system automatically selects the best codec supported by both devices. Check which codec is being used:

```bash
pactl list sinks | grep -i codec
```

## Performance Expectations

### Audio Quality

| Configuration | Sample Rate | Bit Depth | Latency |
|--------------|-------------|-----------|---------|
| Default | 48 kHz | 16-bit | ~50ms |
| High Quality | 96 kHz | 24-bit | ~100ms |
| Low Latency | 44.1 kHz | 16-bit | ~25ms |

### Bluetooth Range

- **Class 1 (USB-BT500):** ~100m line of sight
- **Class 2 (typical):** ~10m through walls
- **Factors:** Walls, interference, obstacles

## Troubleshooting Hardware Issues

### HiFiBerry Not Detected

```bash
# Check if overlay is loaded
vcgencmd get_config dtoverlay

# Should show: hifiberry-dacplusadcpro=
```

### USB Bluetooth Not Working

```bash
# Check if adapter is recognized
lsusb | grep -i bluetooth

# Check Bluetooth controller
hciconfig
```

### Audio Distortion

Possible causes:
1. Insufficient power supply
2. Poor quality audio cables
3. Ground loop (try USB isolator)
4. Buffer size too small

## Future Hardware Support

We plan to test and support:
- Additional Raspberry Pi models
- More HiFiBerry variants
- Other I2S DAC HATs
- Alternative Bluetooth adapters

## Contributing Hardware Information

If you test this project with different hardware:

1. Document your complete setup
2. Note any configuration changes needed
3. Report success or issues on GitHub
4. Include audio quality measurements if possible

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## Where to Buy

### Official Distributors

- **Raspberry Pi:** raspberrypi.com/products
- **HiFiBerry:** hifiberry.com/shop
- **Asus USB-BT500:** Major electronics retailers

### Approximate Costs (USD)

- Raspberry Pi 4B (4GB): $55
- HiFiBerry DAC+ ADC Pro: $50
- Asus USB-BT500: $20
- Power supply: $10
- SD Card (32GB): $10
- **Total:** ~$145

Budget option:
- Raspberry Pi 4B (2GB): $35
- Generic USB DAC: $15
- TP-Link UB400: $10
- **Total:** ~$70
