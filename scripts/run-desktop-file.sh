#!/usr/bin/env bash

if [ -z "$1" ]; then
  exit 1
fi

filename="$(realpath "$1")"
if [ ! -f "$filename" ]; then
  exit 1
fi

is_term="$(grep -m1 -o -Pe '(?<=^Terminal\=).*' "${filename}")"
exec_line="$(grep -m1 -o -Pe '(?<=^Exec\=).*' "${filename}" | sed 's/%[fFuUdDnNickvm]//g')"

if [ -z "$exec_line" ]; then
  exit 1
fi

if [ "$is_term" = "true" ]; then
  hyprctl dispatch exec -- foot -- $exec_line >/dev/null
else
  hyprctl dispatch exec -- $exec_line >/dev/null
fi

