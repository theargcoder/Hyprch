#!/usr/bin/env bash
#
# Update system packages using pacman and AUR helper (wofi GUI + waybar support)
#
# Author: adapted from Jesse Mirabel <github.com/sejjy>
# Converted: October 11, 2025
# License: MIT

HELPER=$(command -v yay trizen pikaur paru pakku pacaur aurman aura |
	head -n 1 | xargs -- basename 2>/dev/null || true)

# timeouts used when querying package lists
CHECK_TIMEOUT=5

check-updates() {
	local repo aur=0

	# Count official repo updates
	repo=$(timeout "$CHECK_TIMEOUT" pacman -Quq 2>/dev/null | wc -l) || repo=0

	# Count AUR updates if helper available
	if [[ -n $HELPER ]]; then
		# some helpers use -Qua / -Quaq flags; try a generic query and fallback
		aur=$(timeout "$CHECK_TIMEOUT" "$HELPER" -Quaq 2>/dev/null | wc -l) || aur=0
	fi

	printf '%d %d' "$repo" "$aur"
}

update-packages() {
	local repo=$1
	local aur=$2

	# Notify start
	notify-send 'System Update' 'Starting update...' -i 'system-software-update' -t 8000

	# Update official packages if any
	if ((repo > 0)); then
		notify-send 'System Update' "Updating ${repo} official package(s) — sudo prompt may appear." -t 8000
		# run pacman update (interactive)
		sudo pacman -Syu
	else
		notify-send 'System Update' 'No official repo updates.' -t 4000
	fi

	# Update AUR packages if helper available and updates exist
	if [[ -n $HELPER ]] && ((aur > 0)); then
		notify-send 'System Update' "Updating ${aur} AUR package(s) with ${HELPER}." -t 8000
		"$HELPER" -Syu
	elif [[ -n $HELPER ]]; then
		notify-send 'System Update' 'No AUR updates.' -t 4000
	fi

	# Final notification & pause for the user
	notify-send 'Update Complete' -i 'package-installed-updated' -t 10000
	# keep a minimal pause so notifications are readable, and if launched from GUI, show a final dialog
	if command -v wofi >/dev/null 2>&1; then
		printf '%s\n' "Update finished. Press Enter to close..." | wofi --dmenu --prompt "Updates"
	else
		echo -e "\nUpdate complete. Press any key to exit..."
		read -r -n 1
	fi
}

display-tooltip() {
	# prints JSON for waybar
	local repo=$1
	local aur=$2
	local tooltip total icon

	tooltip="Official: $repo"
	if [[ -n $HELPER ]]; then
		tooltip+="\nAUR($HELPER): $aur"
	fi

	total=$((repo + aur))

	if ((total > 0)); then
		icon=''
	else
		icon='󰸟'
	fi

	# JSON expected by waybar module
	printf '{ "text": "%s", "tooltip": "%s" }' "$icon" "$tooltip"
}

select-action_wofi() {
	# Show a small wofi menu with the current counts and let the user choose.
	local repo aur menu prompt selection

	read -r repo aur < <(check-updates)

	prompt="Official: $repo — AUR($HELPER): $aur"
	menu=$'Check for updates\nUpdate now\nCancel'

	selection=$(printf '%s\n' "$menu" | wofi --dmenu --prompt "Updates — $prompt" --width 40% --height 30% --insensitive)

	# If user cancelled or selection empty, return non-zero
	if [[ -z "$selection" ]]; then
		return 1
	fi

	case "$selection" in
		'Check for updates')
			# Show a notification with counts
			notify-send 'Update Check' "Official: $repo\nAUR($HELPER): $aur" -t 8000
			;;
		'Update now')
			# Run updates (same as start)
			update-packages "$repo" "$aur"
			;;
		'Cancel'|*)
			return 1
			;;
	esac
}

main() {
	local action=$1
	local repo aur

	case "$action" in
		start)
			# explicit non-interactive start (same as before)
			read -r repo aur < <(check-updates)
			update-packages "$repo" "$aur"
			;;
		menu)
			# GUI menu via wofi
			select-action_wofi
			;;
		*)
			# Default: act as waybar module — print JSON tooltip/icon
			read -r repo aur < <(check-updates)
			display-tooltip "$repo" "$aur"
			;;
	esac
}

main "$@"
