#!/usr/bin/env bash

set -o pipefail

filename="$(realpath "$1")"
size_x=$2
size_y=$3
pos_x=$4
pos_y=$5

no_cache=0

chafa_wrapper() {
  chafa \
    --format sixel \
    --polite on \
    --passthrough none \
    --colors full \
    --optimize 9 \
    --animate off \
    --size "${size_x}x$((size_y - 2))" \
    "$@"
}

mime_description=$(file --brief --mime -- "$filename")
case "$mime_description" in
  image/*)
    bytes="$(stat -c '%s' "$filename")"
    if [ "$bytes" -gt "$((1024 * 1024 * 10))" ]; then # 10 megs
      printf "file too big: disabling image preview\n\n" | fold -w "$size_x"
      magick identify -ping \
        -format '%m %wx%h, %[colorspace], %r' \
        "$filename" 2>&1 | fold -w "$size_x" && success="yes"
    else
      if chafa_wrapper "$filename"; then
        success="yes"
        no_cache=1
      fi
      # display additional info at the bottom
      tput cuf "$pos_x"
      magick identify -ping \
        -format '%m %wx%h, %[colorspace], %r' \
        "$filename" | head -c "$size_x"
    fi
    ;;
  video/*)
    IFS=',' read -r w h fps len codec < <(mediainfo --Inform="Video;%Width%,%Height%,%FrameRate%,%Duration%,%CodecID%" "$filename")
    len="${len%.*}" # remove everything after dot
    len="${len:-0}" # fallback
    pos=2 # 2 means 1/2

    if ffmpeg \
      -ss "$((len / pos))ms" \
      -i "$filename" \
      -vf "scale='min(640,iw)':'min(480,ih)':force_original_aspect_ratio=decrease" \
      -vframes 1 \
      -f apng pipe:1 | chafa_wrapper;
    then
      success="yes"
      no_cache=1
    fi

    # display additional info at the bottom
    tput cuf "$pos_x"
    # covert seconds to hh:mm:ss
    total_sec="$((len / 1000))"
    sec="$((total_sec % 60))"
    min="$(((total_sec / 60) % 60))"
    hr="$((total_sec / 3600))"
    time_string="$([ "$hr" -gt 0 ] && printf "%dh" "$hr")$([ "$min" -gt 0 ] && printf "%dm" "$min")${sec}s"
    printf '%s, %dx%d, %s fps, %s' "$time_string" "$w" "$h" "$fps" "$codec" | head -c "$size_x"
    ;;
  application/pdf*)
    if magick convert \
      -background '#FFFFFF' \
      -alpha deactivate \
      "${filename}[0]" jpg:- | chafa_wrapper;
    then
      success="yes"
      no_cache=1
    fi
    ;;
  audio/*)
    mediainfo "$filename" | \
      awk -F '( +):' '{ gsub(/( +)$/, "", $1); print $1 ($2 ? ":" : "") $2 }' && success="yes"
    ;;
  application/x-tar*|application/zstd*|application/gzip*|application/x-xz*|application/zip*|application/java-archive*|application/x-7z*|application/x-rar*)
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

