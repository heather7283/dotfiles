#!/usr/bin/env bash

filename="$(realpath "$1")"
size_x=$2
size_y=$3
pos_x=$4
pos_y=$5

mime_description=$(file --brief --mime -- "$filename")

case "$mime_description" in
  image/*)
    chafa \
      --format sixel \
      --polite on \
      --colors full \
      --optimize 9 \
      --animate off \
      --size "${size_x}x${size_y}" \
      "$filename" && success="yes"
    exit 1
    ;;
  video/*)
    tmpfile="/tmp/$$_lfvideopreview.png"
    ffmpeg -i "$filename" -vframes 1 "$tmpfile" && \
    chafa \
      --format=sixel \
      --polite=on \
      --colors=full \
      --optimize=9 \
      --animate=off \
      --size="${size_x}x${size_y}" \
      "$tmpfile" && success="yes"
    rm "$tmpfile"
    exit 1
    ;;
  audio/*)
    mediainfo "$filename" && success="yes"
    ;;
  application/x-tar*|application/zstd*|application/gzip*|application/x-xz*)
    tar -tf "$filename" && success="yes"
    ;;
  application/zip*|application/java-archive*)
    unzip -Z1 "$filename" && success="yes"
    ;;
  application/x-7z*)
    7z l "$filename" | awk 'BEGIN { name_start = 999999999999 } /\s*Date\s*Time\s*Attr\s*Size\s*Compressed\s*Name\s*/ { for (i = 0; i <= length($0); i++) { if (substr($0, i, length($0)) == "Name") { name_start = i } } } { if (NR > name_start) { print substr($0, name_start, length($0)) } }'
    ;;
  application/json*)
    jq . "$filename" --color-output && success="yes"
    ;;
  #inode/blockdevice*|inode/chardevice*)
  #  file "$filename"
  #  ;;
esac

if echo "$mime_description" | grep -qP '(.*)charset=(?!binary)'; then
  bat --theme=base16 "$filename" || cat "$filename" && success="yes"
fi

if [ -z "$success" ]; then
  file --brief "$filename" | fold -s -w "$size_x"
  echo ""
  echo "$mime_description"
fi

