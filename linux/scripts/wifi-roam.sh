#!/usr/bin/env bash
# Override defaults via environment variables:
#   WIFI_INTERFACE=wlp3s0 WIFI_SSID=myhomenet ./wifi-roam.sh
INTERFACE="${WIFI_INTERFACE:-wlan0}" # Find your interface with 'ip link'
SSID="${WIFI_SSID:-docksrv}"
THRESHOLD=-75 # Signal level in dBm to start looking
DIFF=15       # Only switch if the new AP is at least 15dBm stronger

while true; do
  # Get current signal strength in dBm
  CURRENT_RSSI=$(awk 'NR==3 {print $4}' /proc/net/wireless | sed 's/\.//')

  if [[ "$CURRENT_RSSI" -lt "$THRESHOLD" ]]; then
    # Check if a significantly better AP exists for the same SSID
    BEST_BSSID=$(nmcli -t -f BSSID,SIGNAL,SSID dev wifi | grep "$SSID" | sort -t: -k2 -nr | head -n1 | cut -d: -f1-6)

    # Force a re-evaluation
    nmcli device wifi rescan
    nmcli device connect "$INTERFACE" bssid "$BEST_BSSID"
  fi
  sleep 15
done
