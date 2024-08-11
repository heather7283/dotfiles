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
      --size "$((size_x))x$((size_y - 2))" \
      "$filename";
    then success="yes"; no_cache=1; fi

    # display additional info at the bottom
    tput cuf "$pos_x"
    magick identify -format '%m %wx%h, %[bit-depth]bit, %[colorspace], %r' "$filename" | head -c "$size_x"
    ;;
  video/*)
    len="$(mediainfo --Inform='Video;%Duration%' "$filename")"
    len="${len%.*}" # remove everything after dot
    len="${len:-0}" # fallback
    pos=2 # 2 means 1/2

    tmpfile="$(mktemp -t "$$_lfvideopreview_XXXXXX.png")"
    if ffmpeg -y -ss "$((len / pos))ms" -i "$filename" -vframes 1 "$tmpfile" && \
    chafa \
      --format=sixel \
      --polite=on \
      --colors=full \
      --optimize=9 \
      --animate=off \
      --size="$((size_x))x$((size_y - 2))" \
      "$tmpfile";
    then success="yes"; no_cache=1; fi
    rm -f "$tmpfile"

    # display additional info at the bottom
    IFS=',' read -r w h fps len codec < <(mediainfo --Inform="Video;%Width%,%Height%,%FrameRate%,%Duration%,%CodecID%" "$filename")
    tput cuf "$pos_x"
    len="${len%.*}"
    printf '%s, %dx%d, %s fps, %s' "$((len / 1000))s" "$w" "$h" "$fps" "$codec" | head -c "$size_x"
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
    mediainfo "$filename" | \
      awk -F '( +):' '{ gsub(/( +)$/, "", $1); print $1 ($2 ? ":" : "") $2 }' && success="yes"
    ;;
  application/x-tar*|application/zstd*|application/gzip*|application/x-xz*|application/zip*|application/java-archive*|application/x-7z*|application/x-rar)
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

