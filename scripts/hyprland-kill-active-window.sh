#!/bin/sh

tab='	'
IFS="$tab"

result="$(hyprctl activewindow -j | jq -r '{ a: .address, b: .pid, c: .initialClass, d: .title } | join("\t")')"
set -- $result
addr="$1"
pid="$2"
initial_class="$3"
title="$4"

hyprctl dispatch closewindow address:"$addr"

# prevent killing foot server
case "$initial_class" in
*foot*)
    exit;;
esac

sleep 5

# if process has no windows opened but is still alive after 5 seconds, kill it
if ps -p "$pid" && hyprctl clients -j | jq -e --arg pid "$pid" '[.[] | select(.pid == ($pid | tonumber))] | length < 1'; then
    notify-send "Killed PID ${pid}" "Window ${title} was SIGTERMed after 5 seconds"
    kill -TERM "$pid"
fi

