#!/usr/bin/env bash

filename="$(realpath "$1")"

mime_description=$(file --brief --mime -- "$filename")

case "$mime_description" in
  image/*)
    exec mvi "$filename"
    ;;
  video/*)
    exec mpv --force-window=immediate "$filename"
    ;;
  audio/*)
    exec mpv --no-video "$filename"
esac

if [[ "$mime_description" =~ charset= ]] && [[ ! "$mime_description" =~ charset=binary ]]; then
  exec "$EDITOR" "$filename"
fi

exec xdg-open "$filename"

