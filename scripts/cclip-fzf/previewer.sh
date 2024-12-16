#!/usr/bin/env -S bash

IFS=$'\t' read -r id mime timestamp preview <<<"$1"

chafa_wrapper() {
    chafa \
        -f sixels \
        --align center \
        --scale max \
        --optimize 9 \
        --view-size "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}"
}

yt_cache_dir=~/.cache/yt-thumbnails
youtube_preview() {
    video_id="${1:?}"
    [ -d "$yt_cache_dir" ] || mkdir -p "$yt_cache_dir" || return
    cache_file="${yt_cache_dir}/${video_id}.jpg"
    thumbnail_url="https://img.youtube.com/vi/${video_id}/3.jpg"
    if [ ! -f "$cache_file" ]; then
        curl -s "$thumbnail_url" >"$cache_file" || { rm "$cache_file"; return; }
    fi
    chafa_wrapper <"$cache_file" && success=1
}

success=0

# images
if [[ "$mime" =~ ^image/.*$ ]]; then
  cclip get "$id" | chafa_wrapper
  success=1
# hex colors
elif [[ "$preview" =~ ^(#|0x)?[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$ ]]; then
  item="${preview#\#}"
  item="${item#0x}"
  r="$((16#${item:0:2}))"
  g="$((16#${item:2:2}))"
  b="$((16#${item:4:2}))"
  echo "#$item"
  echo "$r $g $b"
  printf "\033[48;2;${r};${g};${b}m %*s \033[0m" "$FZF_PREVIEW_COLUMNS" ""
  success=1
# youtube
elif [[ "$preview" =~ ^https:\/\/(www\.)?youtu\.?be(\.com\/watch\?v=)? ]]; then
  url="${preview#https://www.youtube.com/watch?v=}"
  url="${url#https://youtu.be/}"
  url="${url%%&*}"
  url="${url%"${url##*[![:space:]]}"}" # strip trailing whitespace
  youtube_preview "$url"
fi

# fallback
if [ "$success" = 0 ]; then
  cclip get "$id" | sed -e "s/.\{${FZF_PREVIEW_COLUMNS}\}/&\n/g"
fi

