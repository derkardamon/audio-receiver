# Quick Fix Reference

## Wrong Device Name / Connection Fails

If your device shows as "piupiu-stream" instead of "PiuPiu-Audio" or connections fail with "ignore device":

```bash
cd ~/audio-receiver
sudo ./scripts/fix-bluetooth-name.sh
sudo reboot
```

## Can't Pair / Pairing Issues

```bash
cd ~/audio-receiver
sudo ./scripts/fix-pairing.sh
```

## No Audio Output

```bash
cd ~/audio-receiver
sudo ./scripts/fix-pipewire.sh
```

## Check System Status

```bash
cd ~/audio-receiver
./scripts/check-status.sh
```

## Watch Bluetooth Pairing Live

```bash
sudo journalctl -u bluetooth-autopair -f
```

## Watch Bluetooth Service Live

```bash
sudo journalctl -u bluetooth -f
```

## Manual Bluetooth Control

```bash
bluetoothctl
> power on
> discoverable on
> pairable on
> agent NoInputNoOutput
> default-agent
> exit
```

## Unpair All Devices

```bash
cd ~/audio-receiver
sudo ./scripts/unpair-all.sh
```

## Fix Everything

```bash
cd ~/audio-receiver
sudo ./scripts/fix-all.sh
```
