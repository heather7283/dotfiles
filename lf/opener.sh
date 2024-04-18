#!/usr/bin/env bash

filename="$(realpath "$1")"

mime_description=$(file --brief --mime -- "$filename")

case "$mime_description" in
  image/*)
    exec imv "$filename"
    ;;
  video/*|audio/*)
    exec mpv "$filename"
    ;;
esac

if echo "$mime_description" | grep -qP '(.*)charset=(?!binary)'; then
  exec nvim "$filename"
fi

exec xdg-open "$filename"

