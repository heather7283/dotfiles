#!/usr/bin/env bash

set -o pipefail

filename="$(realpath "$1")"
size_x=$2
size_y=$3
pos_x=$4
pos_y=$5

no_cache=0

mime_description=$(file --brief --mime -- "$filename")
case "$mime_description" in
  image/*)
    if chafa \
      --format sixel \
      --polite on \
      --colors full \
      --optimize 9 \
      --animate off \
      --size "$((size_x))x$((size_y - 1))" \
      "$filename";
    then success="yes"; no_cache=1; fi
    ;;
  video/*)
    tmpfile="/tmp/$$_lfvideopreview.png"
    if ffmpeg -i "$filename" -vframes 1 "$tmpfile" && \
    chafa \
      --format=sixel \
      --polite=on \
      --colors=full \
      --optimize=9 \
      --animate=off \
      --size="$((size_x))x$((size_y - 1))" \
      "$tmpfile";
    then success="yes"; no_cache=1; fi
    rm -f "$tmpfile" 
    ;;
  application/pdf*)
    if magick convert -background '#FFFFFF' -alpha deactivate "${filename}[0]" png:- | \
    chafa \
      --format=sixel \
      --polite=on \
      --colors=full \
      --optimize=9 \
      --animate=off \
      --size="$((size_x))x$((size_y - 1))"; then success="yes"; no_cache=1; fi
    ;;
  audio/*)
    mediainfo "$filename" && success="yes"
    ;;
  application/x-tar*|application/zstd*|application/gzip*|application/x-xz*|application/zip*|application/java-archive*|application/x-7z*)
    bsdtar -tf "$filename" && success="yes"
    ;;
  application/json*)
    jq . "$filename" --color-output && success="yes"
    ;;
esac

if [ -z "$success" ] && [[ "$mime_description" =~ charset= ]] && [[ ! "$mime_description" =~ charset=binary ]]; then
  bat "$filename" || cat "$filename" && success="yes"
fi

if [ -z "$success" ]; then
  file --brief "$filename" | fold -s -w "$size_x"
  echo ""
  echo "$mime_description"
fi

exit $no_cache

