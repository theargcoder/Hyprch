#!/usr/bin/env bash
#
# Connect to a Bluetooth device using bluetoothctl and wofi (dmenu mode)
#
# Author: adapted from Jesse Mirabel <github.com/sejjy>
# Converted: October 11, 2025
# License: MIT

TIMEOUT=10

ensure-on() {
	local status
	status=$(bluetoothctl show | awk '/Powered/ {print $2}' || echo 'off')

	if [[ $status == 'no' || $status == 'off' ]]; then
		bluetoothctl power on >/dev/null 2>&1
		notify-send 'Bluetooth' 'Powered on' -i 'network-bluetooth-activated' -r 1925 -t 10000
	fi
}

scan-for-devices() {
	# Start scanning in the background for $TIMEOUT seconds and notify the user.
	# bluetoothctl --timeout WILL stop itself after $TIMEOUT seconds.
	bluetoothctl --timeout "$TIMEOUT" scan on >/dev/null 2>&1 &

	notify-send "Bluetooth" "Scanning for devices for ${TIMEOUT}s…" -i 'network-bluetooth' -r 1926 -t 10000
	# wait a bit to allow devices to be discovered - bluetoothctl handles timeout itself
	sleep "$TIMEOUT"

	# try to be polite and turn scanning off (may already have stopped)
	bluetoothctl scan off >/dev/null 2>&1 || true
}

get-device-list() {
	# Output lines formatted for wofi: "ADDRESS<TAB>NAME [connected]"
	local line addr name connected status
	local -a list=()

	# Iterate devices; bluetoothctl devices lines look like: "Device XX:XX:XX:XX:XX:XX Name"
	while IFS= read -r line; do
		# skip empty lines
		[[ -z "$line" ]] && continue

		addr=$(awk '{print $2}' <<<"$line")
		name=$(echo "$line" | cut -d' ' -f 3-)

		connected=$(bluetoothctl info "$addr" 2>/dev/null | awk '/Connected/ {print $2}')
		status=""
		if [[ $connected == "yes" ]]; then
			status=" [connected]"
		fi

		# Use a real tab between address and name so wofi shows the name nicely
		list+=("$addr"$'\t'"$name$status")
	done < <(bluetoothctl devices | grep '^Device' || true)

	if [[ ${#list[@]} -eq 0 ]]; then
		notify-send 'Bluetooth' 'No devices found' -i 'package-broken'
		return 1
	fi

	# Print newline-separated items (wofi reads stdin)
	printf '%s\n' "${list[@]}"
}

select-device() {
	# $1: multiline list (address<TAB>name)
	local list="$1"
	local selection address

	# Send list to wofi (dmenu mode). Adjust --width/--height/--prompt as you like.
	# wofi will print the selected line to stdout; we capture it.
	selection=$(printf '%s\n' "$list" | wofi --dmenu --prompt 'Bluetooth Devices' --width 50% --height 50% --insensitive)

	# If user cancelled selection, exit non-zero
	if [[ -z "$selection" ]]; then
		return 1
	fi

	# Extract address (first whitespace-separated token)
	address=$(awk '{print $1}' <<<"$selection")

	if [[ -z "$address" ]]; then
		return 1
	fi

	# If already connected, notify and return non-zero
	local connected
	connected=$(bluetoothctl info "$address" 2>/dev/null | awk '/Connected/ {print $2}')
	if [[ $connected == 'yes' ]]; then
		notify-send 'Bluetooth' 'Already connected to this device' -i 'package-install' -t 10000
		return 1
	fi

	printf '%s' "$address"
}

pair-and-connect() {
	local address=$1
	local paired

	paired=$(bluetoothctl info "$address" 2>/dev/null | awk '/Paired/ {print $2}')

	if [[ $paired == 'no' || -z $paired ]]; then
		notify-send 'Bluetooth' 'Pairing...' -i 'dialog-information' -r 1927 -t 10000
		if ! timeout "$TIMEOUT" bluetoothctl pair "$address" >/dev/null 2>&1; then
			notify-send 'Bluetooth' 'Failed to pair' -i 'package-purge' -t 10000
			return 1
		fi
	fi

	notify-send 'Bluetooth' 'Connecting...' -i 'dialog-information' -r 1928
	if timeout "$TIMEOUT" bluetoothctl connect "$address" >/dev/null 2>&1; then
		notify-send 'Bluetooth' 'Successfully connected' -i 'package-install'
	else
		notify-send 'Bluetooth' 'Failed to connect' -i 'package-purge'
		return 1
	fi
}

main() {
	local list address

	ensure-on
	scan-for-devices

	list=$(get-device-list) || exit 1

	# launch wofi and get chosen address
	address=$(select-device "$list") || exit 1

	pair-and-connect "$address" || exit 1
}

main "$@"
