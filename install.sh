#!/bin/bash
set -e

echo "========================================="
echo "Raspberry Pi Audio Receiver Installation"
echo "========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
apt-get install -y \
    bluez \
    bluez-tools \
    pipewire \
    pipewire-audio \
    wireplumber \
    pipewire-pulse \
    libspa-0.2-bluetooth \
    bluez-alsa-utils \
    git

# Disable internal Bluetooth
echo "Disabling internal Bluetooth..."
if ! grep -q "dtoverlay=disable-bt" /boot/config.txt; then
    echo "dtoverlay=disable-bt" >> /boot/config.txt
fi

# Configure HiFiBerry DAC+ ADC Pro
echo "Configuring HiFiBerry DAC+ ADC Pro..."
# Remove existing audio overlays
sed -i '/^dtparam=audio=/d' /boot/config.txt
sed -i '/^dtoverlay=hifiberry/d' /boot/config.txt

# Add HiFiBerry overlay
if ! grep -q "dtoverlay=hifiberry-dacplusadcpro" /boot/config.txt; then
    echo "dtoverlay=hifiberry-dacplusadcpro" >> /boot/config.txt
fi

# Blacklist internal audio
echo "Blacklisting internal audio..."
mkdir -p /etc/modprobe.d
if ! grep -q "blacklist snd_bcm2835" /etc/modprobe.d/raspi-blacklist.conf 2>/dev/null; then
    echo "blacklist snd_bcm2835" > /etc/modprobe.d/raspi-blacklist.conf
fi

# Configure sound card ordering
echo "Configuring sound card order..."
cp -f configs/alsa/alsa-base.conf /etc/modprobe.d/alsa-base.conf

# Create configuration directories
echo "Creating configuration directories..."
mkdir -p /etc/pipewire

# Copy configuration files
echo "Installing configuration files..."
cp -f configs/bluetooth/main.conf /etc/bluetooth/main.conf
cp -f configs/pipewire/pipewire.conf /etc/pipewire/pipewire.conf
cp -f configs/pipewire/pipewire-pulse.conf /etc/pipewire/pipewire-pulse.conf

# Note: WirePlumber 0.5+ uses modern configuration system
# Old Lua configs are no longer supported or needed
# Default WirePlumber configuration is optimized for Bluetooth audio

# Install Bluetooth auto-pair script
echo "Installing Bluetooth auto-pair service..."
cp -f scripts/bluetooth-autopair /usr/local/bin/bluetooth-autopair
chmod +x /usr/local/bin/bluetooth-autopair

cp -f services/bluetooth-autopair.service /etc/systemd/system/bluetooth-autopair.service

# Enable PipeWire for the user
echo "Enabling PipeWire..."
systemctl --global disable pulseaudio.service pulseaudio.socket 2>/dev/null || true
systemctl --global enable pipewire pipewire-pulse wireplumber

# Enable lingering for the sudo user so PipeWire starts at boot
if [ -n "$SUDO_USER" ]; then
    loginctl enable-linger $SUDO_USER
fi

# Enable Bluetooth services
echo "Enabling Bluetooth services..."
systemctl enable bluetooth
systemctl enable bluetooth-autopair

# Add user to bluetooth group
if [ -n "$SUDO_USER" ]; then
    usermod -a -G bluetooth,audio $SUDO_USER
fi

echo ""
echo "========================================="
echo "Installation complete!"
echo "========================================="
echo ""
echo "Please reboot your Raspberry Pi for changes to take effect."
echo "After reboot, the Bluetooth adapter will be discoverable as 'RaspberryPi-Audio'"
echo "and will auto-pair with any device without requiring verification."
echo ""
echo "To reboot now, run: sudo reboot"
