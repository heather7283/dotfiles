#!/bin/sh

selected="$(fzf <~/.config/scripts/unicode-picker/unicode_list.txt \
    -d "$(printf '\t')" \
    --nth=2 \
    --bind 'ctrl-y:execute-silent(printf '%s' {1} | wl-copy -t text/plain\;charset=utf-8)')"
[ -z "$selected" ] && exit

set -- $selected
char="$1"
name="$2"

wl-copy -t "text/plain;charset=utf-8" "$char"
