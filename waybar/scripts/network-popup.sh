#!/usr/bin/env bash
# GUI Wi-Fi selector popup using wofi + nmcli
# With scanning message and password prompt (no terminal)

TIMEOUT=5

# Enable Wi-Fi if disabled
if [[ $(nmcli radio wifi) == "disabled" ]]; then
  nmcli radio wifi on
  notify-send "Wi-Fi Enabled" -i "network-wireless-on" -r 1125 -t 5000
fi

# 1️⃣ Show scanning message
echo "Scanning for networks..." | \
wofi --dmenu --prompt "Wi-Fi" --width 280 --height 100 &
wofi_pid=$!

# 2️⃣ Rescan networks
nmcli device wifi rescan >/dev/null 2>&1
for ((i = 1; i <= TIMEOUT; i++)); do
  networks=$(nmcli -t -f SSID device wifi list | grep -v '^$' | sort -u)
  [[ -n "$networks" ]] && break
  sleep 1
done

# Close "scanning" popup
kill "$wofi_pid" >/dev/null 2>&1
sleep 0.1

# 3️⃣ If none found
if [[ -z "$networks" ]]; then
  notify-send "Wi-Fi" "No networks found" -i "package-broken" -t 10000
  exit 1
fi

# 4️⃣ Current connection
current=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes"{print $2}')

# 5️⃣ Highlight current
menu=$(echo "$networks" | sed "s/^$current$/★ $current/")

# 6️⃣ Select SSID
choice=$(echo "$menu" | \
wofi --dmenu --prompt "Select Wi-Fi:" --width 320 --height 400)

[[ -z "$choice" ]] && exit 0
choice=${choice#★ }

if [[ "$choice" == "$current" ]]; then
  notify-send "Wi-Fi" "Already connected to $choice" -i "network-wireless-connected" -t 5000
  exit 0
fi

# 7️⃣ Check if we already have a saved connection
if nmcli connection show | grep -q "$choice"; then
  if nmcli device wifi connect "$choice"; then
    notify-send "Wi-Fi" "Connected to $choice" -i "network-wireless-connected" -t 5000
    exit 0
  else
    notify-send "Wi-Fi" "Failed to reconnect to $choice" -i "network-wireless-off" -t 10000
    exit 1
  fi
fi

# 8️⃣ Ask for password (if new network)
password=$(echo "" | wofi --dmenu --password --prompt "Password for $choice" --width 320 --height 120)

# If cancelled
[[ -z "$password" ]] && exit 0

# 9️⃣ Connect with password
if nmcli device wifi connect "$choice" password "$password"; then
  notify-send "Wi-Fi" "Connected to $choice" -i "network-wireless-connected" -t 5000
else
  notify-send "Wi-Fi" "Failed to connect to $choice" -i "network-wireless-off" -t 10000
fi
