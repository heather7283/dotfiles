#!/bin/sh

filepath="$1"

window_title="$(hyprctl activewindow | awk '/\s+title:/ { print $2 }' | sed -Ee 's/[[:space:]]+//g')"
[ -z "$window_title" ] && window_title='unknown_title'

ext="${filepath##*.}"
filepath_without_ext="${filepath%.*}"

new_filepath="${filepath_without_ext}-${window_title}.${ext}"

if mv "$filepath" "$new_filepath"; then
    notify-send "Replay saved" "${new_filepath}"
else
    notify-send "Replay saved" "${filepath}"
fi

