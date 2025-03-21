#!/bin/sh

filepath="$1"

window_title="$(hyprctl activewindow -j | jq -r '.title' | sed -Ee 's/[[:space:]]+/_/g')"
[ -z "$window_title" ] && window_title='unknown_title'

ext="${filepath##*.}"
filepath_without_ext="${filepath%.*}"

new_filepath="${filepath_without_ext}-${window_title}.${ext}"

if mv "$filepath" "$new_filepath"; then
    res="$(notify-send -A 'default=Copy path' "Replay saved" "${new_filepath}")"
    if [ "$res" = 'default' ]; then
        wl-copy "$new_filepath"
    fi
else
    res="$(notify-send -A 'default=Copy path' "Replay saved" "${filepath}")"
    if [ "$res" = 'default' ]; then
        wl-copy "$filepath"
    fi
fi

