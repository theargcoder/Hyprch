#!/usr/bin/env bash
#
# Connect to a Bluetooth device using bluetoothctl and wofi (dmenu mode)
# Initial menu asks: Connect or Disconnect (then acts accordingly).
#
# Author: adapted from Jesse Mirabel <github.com/sejjy>
# Converted: October 11, 2025
# License: MIT

TIMEOUT=5

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
	bluetoothctl --timeout "$TIMEOUT" scan on >/dev/null 2>&1 &

	notify-send "Bluetooth" "Scanning for devices for ${TIMEOUT}s…" -i 'network-bluetooth' -r 1926 -t 10000
	sleep "$TIMEOUT"

	# stop scanning if still on
	bluetoothctl scan off >/dev/null 2>&1 || true
}

# Disconnect every currently connected device
disconnect_all() {
	local line addr connected
	local -a disconnected failed

	while IFS= read -r line; do
		[[ -z "$line" ]] && continue
		addr=$(awk '{print $2}' <<<"$line")
		connected=$(bluetoothctl info "$addr" 2>/dev/null | awk '/Connected/ {print $2}')
		if [[ $connected == "yes" ]]; then
			if timeout "$TIMEOUT" bluetoothctl disconnect "$addr" >/dev/null 2>&1; then
				disconnected+=("$addr")
			else
				failed+=("$addr")
			fi
		fi
	done < <(bluetoothctl devices | grep '^Device' || true)

	if (( ${#disconnected[@]} == 0 && ${#failed[@]} == 0 )); then
		notify-send 'Bluetooth' 'No connected devices to disconnect' -i 'network-bluetooth' -t 8000
		return 1
	fi

	local msg=""
	if (( ${#disconnected[@]} > 0 )); then
		msg+="Disconnected: ${#disconnected[@]}"
	fi
	if (( ${#failed[@]} > 0 )); then
		[[ -n "$msg" ]] && msg+=" — "
		msg+="Failed: ${#failed[@]}"
	fi

	notify-send 'Bluetooth' "$msg" -i 'network-bluetooth' -t 10000

	# Show details in a small wofi box (optional)
	if command -v wofi >/dev/null 2>&1; then
		local details=""
		if (( ${#disconnected[@]} > 0 )); then
			details+="Disconnected:\n$(printf '%s\n' "${disconnected[@]}")\n"
		fi
		if (( ${#failed[@]} > 0 )); then
			details+="Failed:\n$(printf '%s\n' "${failed[@]}")\n"
		fi
		printf '%s' "$details" | wofi --dmenu --prompt "Disconnect results" --width 50% --height 40% --insensitive >/dev/null 2>&1 || true
	fi

	if (( ${#failed[@]} > 0 )); then
		return 2
	else
		return 0
	fi
}

# Disconnect a single device by address
disconnect_device() {
	local addr=$1
	if [[ -z "$addr" ]]; then
		return 1
	fi

	if timeout "$TIMEOUT" bluetoothctl disconnect "$addr" >/dev/null 2>&1; then
		notify-send 'Bluetooth' "Disconnected $addr" -i 'network-bluetooth' -t 8000
		return 0
	else
		notify-send 'Bluetooth' "Failed to disconnect $addr" -i 'network-bluetooth' -t 10000
		return 2
	fi
}

# Build and return a newline-separated list of devices (ADDRESS<TAB>NAME [connected])
get-device-list() {
	local line addr name connected status
	local -a list=()

	while IFS= read -r line; do
		[[ -z "$line" ]] && continue
		addr=$(awk '{print $2}' <<<"$line")
		name=$(echo "$line" | cut -d' ' -f 3-)
		connected=$(bluetoothctl info "$addr" 2>/dev/null | awk '/Connected/ {print $2}')
		status=""
		if [[ $connected == "yes" ]]; then
			status=" [connected]"
		fi
		list+=("$addr"$'\t'"$name$status")
	done < <(bluetoothctl devices | grep '^Device' || true)

	if [[ ${#list[@]} -eq 0 ]]; then
		notify-send 'Bluetooth' 'No devices found' -i 'package-broken' -t 8000
		return 1
	fi

	printf '%s\n' "${list[@]}"
}

# Build a menu that lists connected devices + an "ALL" entry for disconnecting
disconnect_menu() {
	local line addr name connected
	local -a list=()

	# Top option to disconnect all
	list+=("ALL"$'\t'"Disconnect all connected devices")

	# Append only connected devices
	while IFS= read -r line; do
		[[ -z "$line" ]] && continue
		addr=$(awk '{print $2}' <<<"$line")
		name=$(echo "$line" | cut -d' ' -f 3-)
		connected=$(bluetoothctl info "$addr" 2>/dev/null | awk '/Connected/ {print $2}')
		if [[ $connected == "yes" ]]; then
			list+=("$addr"$'\t'"$name")
		fi
	done < <(bluetoothctl devices | grep '^Device' || true)

	# If there are no connected devices, still show the menu (user can choose ALL which will report none)
	selection=$(printf '%s\n' "${list[@]}" | wofi --dmenu --prompt 'Disconnect: choose All or a device' --width 45% --height 50% --insensitive)

	# cancelled?
	if [[ -z "$selection" ]]; then
		return 1
	fi

	local addr_selected
	addr_selected=$(awk '{print $1}' <<<"$selection")

	if [[ "$addr_selected" == "ALL" ]]; then
		disconnect_all
		return $?
	else
		disconnect_device "$addr_selected"
		return $?
	fi
}

select-device() {
	# $1: multiline list (address<TAB>name)
	local list="$1"
	local selection address

	selection=$(printf '%s\n' "$list" | wofi --dmenu --prompt 'Bluetooth Devices' --width 50% --height 50% --insensitive)

	# If user cancelled selection, exit non-zero
	if [[ -z "$selection" ]]; then
		return 1
	fi

	# Extract address (first whitespace-separated token)
	address=$(awk '{print $1}' <<<"$selection")

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

	notify-send 'Bluetooth' 'Connecting...' -i 'dialog-information' -r 1928 -t 10000
	if timeout "$TIMEOUT" bluetoothctl connect "$address" >/dev/null 2>&1; then
		notify-send 'Bluetooth' 'Successfully connected' -i 'package-install' -t 10000
	else
		notify-send 'Bluetooth' 'Failed to connect' -i 'package-purge' -t 10000
		return 1
	fi
}

main() {
	local list address

	# top-level choice: Connect or Disconnect
	local action
	action=$(printf 'Connect\nDisconnect' | wofi --dmenu --prompt 'Choose action' --width 28% --height 20% --insensitive)

	# If cancelled or empty, exit cleanly
	if [[ -z "$action" ]]; then
		exit 0
	fi

	if [[ "$action" == "Disconnect" ]]; then
		# Open the disconnect menu; exit with its result code
		disconnect_menu
		exit $?
	fi

	# Otherwise proceed with normal scanning + connect flow
	ensure-on
	scan-for-devices

	list=$(get-device-list) || exit 1

	address=$(select-device "$list") || exit $?

	pair-and-connect "$address" || exit 1
}

main "$@"
