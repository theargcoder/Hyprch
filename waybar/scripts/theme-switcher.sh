#!/usr/bin/env bash
#
# Switch waybar themes and export matching fzf colors
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 22, 2025
# License: MIT

FILES=("$HOME/.config/waybar/themes/"*.css)
FILE=$HOME/.config/waybar/theme.css
THEME=$(head -n 1 "$FILE" | awk '{print $2}')

display-tooltip() {
	local name=$THEME
	name="<span text_transform='capitalize'>${name//-/ }</span>"

	echo "{ \"text\": \"󰍜\", \"tooltip\": \"Theme: $name\" }"
}

main() {
	local action=$1

	case $action in
		next | prev)
			switch-theme "$action"

			pkill waybar 2>/dev/null || true
			nohup waybar >/dev/null 2>&1 &
			;;
		fzf) export-colors ;;
		*) display-tooltip ;;
	esac
}

main "$@"
