#!/bin/sh

selected="$(fzf <~/.config/scripts/emoji-picker/emoji-list.txt)"
[ -z "$selected" ] && exit

set -- $selected
emoji="$1"

wl-copy -t "text/plain;charset=utf-8" "$emoji"

