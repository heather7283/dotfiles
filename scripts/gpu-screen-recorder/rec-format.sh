#!/bin/sh

rec_dir=~/videos/recordings/button/
recorder_pidfile="${rec_dir}/pid"
mode_file="${rec_dir}/mode"

label='REC'
class='inactive'

if [ -f "$recorder_pidfile" ]; then
    class='active'
    if [ -f "$mode_file" ]; then
        mode="$(cat "$mode_file")"
        if [ "$mode" = 'replay' ]; then
            class='active-replay'
        fi
    fi
fi

printf '{ "text": "%s", "class": "%s" }' "$label" "$class"

