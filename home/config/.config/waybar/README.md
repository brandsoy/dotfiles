# Lenovo ThinkPad X13 Yoga Gen 2 (20W8) - Arch Linux Configuration

This directory contains the configuration for Waybar, tailored specifically for the Lenovo ThinkPad X13 Yoga Gen 2 (Type 20W8) running Arch Linux.

## Hardware & Peripheral Details

### Network (WiFi & Ethernet)
- **WiFi Interface:** `wlp0s20f3` (Standard Intel AX201/AX210 usually found in this model)
- **Ethernet:** This model uses a dongle or dock. Detected as `enp34s0u1u2` in previous sessions.
- **Configuration:** The Waybar `network` module is set to auto-detect the active interface, prioritizing Ethernet if plugged in, then falling back to WiFi.

### Audio
- **Sound System:** PipeWire (running with `pipewire-pulse` compatibility).
- **Control:**
  - **Click:** Mutes/Unmutes.
  - **Scroll:** Adjusts volume.
  - **Right-Click:** Opens `pavucontrol` (PulseAudio Volume Control).

### Power & Battery
- **Primary Battery:** `BAT0`
  - Path: `/sys/class/power_supply/BAT0`
- **Power Supply:** USB-C charging (UCSI interface).

### Display & Backlight
- **Backlight Device:** `intel_backlight`
  - Path: `/sys/class/backlight/intel_backlight`
- **Control:** Integrated into Waybar using the native `backlight` module.

## Maintenance

### Reloading Configuration
To apply changes after editing `config.jsonc` or `style.css`:
```bash
./launch.sh
```

### File Structure
- `config.jsonc`: Main layout and module configuration.
- `style.css`: Visual styling (CSS).
- `colors/one-dark.css`: Color variables for the One Dark theme.
- `launch.sh`: Script to cleanly restart the bar.
