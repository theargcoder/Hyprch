#!/usr/bin/env bash
#
# Launch power menu using wofi (dmenu mode)
#
# Author: adapted from Jesse Mirabel <github.com/sejjy>
# Converted: October 11, 2025
# License: MIT

LIST=(
	'Lock'
	'Shutdown'
	'Reboot'
	'Logout'
	'Hibernate'
	'Suspend'
)

select-action() {
	local action

	# Build newline-separated list for wofi
	local menu
	menu=$(printf '%s\n' "${LIST[@]}")

	# Launch wofi in dmenu mode
	# Adjust --width/--height/--prompt to taste
	action=$(printf '%s\n' "$menu" | wofi --dmenu --prompt 'Power Menu' --width 30% --height 35% --insensitive)

	# If user cancelled, return non-zero
	if [[ -z $action ]]; then
		return 1
	else
		printf '%s' "$action"
	fi
}

do-lock() {
	# Prefer loginctl lock-session; fallback to common screen lockers
	if command -v loginctl >/dev/null 2>&1; then
		loginctl lock-session 2>/dev/null || true
	elif command -v swaylock >/dev/null 2>&1; then
		swaylock -f &
	elif command -v slock >/dev/null 2>&1; then
		slock &
	else
		notify-send 'Lock' 'No locker found' -i 'dialog-warning' -t 5000
		return 1
	fi
}

main() {
	local action
	action=$(select-action) || exit 1

	case $action in
		'Lock')
			do-lock
			;;
		'Shutdown')
			notify-send 'Power' 'Shutting down…' -i 'system-shutdown' -t 5000
			systemctl poweroff
			;;
		'Reboot')
			notify-send 'Power' 'Rebooting…' -i 'system-reboot' -t 5000
			systemctl reboot
			;;
		'Logout')
			# Try to terminate the current session; fallback to kill XDG_SESSION_ID if unset
			if [[ -n "$XDG_SESSION_ID" ]]; then
				loginctl terminate-session "$XDG_SESSION_ID"
			else
				# attempt to find the session id for current user and terminate it
				local sid
				sid=$(loginctl list-sessions --no-legend | awk -v u="$USER" '$3==u {print $1; exit}')
				if [[ -n "$sid" ]]; then
					loginctl terminate-session "$sid"
				else
					notify-send 'Logout' 'Could not determine session to terminate' -i 'dialog-warning' -t 5000
					exit 1
				fi
			fi
			;;
		'Hibernate')
			notify-send 'Power' 'Hibernating…' -i 'battery' -t 5000
			systemctl hibernate
			;;
		'Suspend')
			notify-send 'Power' 'Suspending…' -i 'battery' -t 5000
			systemctl suspend
			;;
		*)
			# Unknown selection (defensive)
			exit 1
			;;
	esac
}

main "$@"
