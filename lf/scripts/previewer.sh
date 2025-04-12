#!/bin/sh

filename="$(realpath "$1")"
size_x="$2"
size_y="$3"
pos_x="$4"
pos_y="$5"

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

image_preview() {
  bytes="$(stat -c '%s' "$filename")"
  if [ "$bytes" -gt 10485760 ]; then # 10 megs
    printf "no image preview\nfile too big\n\n"
    magick identify -ping \
      -format '%m %wx%h, %[colorspace], %r' \
      "${filename}[0]" 2>&1 && success="yes"
  else
    if chafa_wrapper "$filename"; then
      success="yes"
      no_cache=1
      # horizontal absolute cursor movement to column pos_x + 1
      printf '\033[%dG' "$((pos_x + 1))"
    fi
    # display additional info at the bottom
    magick identify -ping \
      -format '%m %wx%h, %[colorspace], %r' \
      "${filename}[0]" | head -c "$size_x"
  fi
}

video_preview() {
  tmpfile="${TMPDIR:-/tmp}/lf_preview_ffmpeg_$$.txt"
  if ffmpeg -hide_banner \
    -i "$filename" \
    -vf 'scale=640:480:force_original_aspect_ratio=decrease' \
    -vframes 1 \
    -f image2pipe -vcodec png - 2>"$tmpfile" | chafa_wrapper
  then
    success="yes"
    no_cache=1
    printf '\033[%dG' "$((pos_x + 1))"

    awk -v len="$size_x" '/^  Duration:/ { gsub(/^  Duration: /, ""); gsub(/\..*$/, ""); dur=$0 } /^  Stream #0:0.+?: Video: / { gsub(/^.+?Video: /, ""); gsub(/ +?\([^)]*\)/, ""); gsub(/ +?\[[^]]*\]/, ""); out=dur ", " $0; print substr(out, 1, len); exit }' "$tmpfile"
  fi
  rm "$tmpfile" 2>/dev/null
}

pdf_preview() {
  if magick \
    "${filename}[0]" \
    -background '#FFFFFF' \
    -alpha deactivate \
    jpg:- | chafa_wrapper;
  then
    success="yes"
    no_cache=1
  fi
}

audio_preview() {
  mediainfo "$filename" | \
    awk -F '( +):' '{ gsub(/( +)$/, "", $1); print $1 ($2 ? ":" : "") $2 }' && success="yes"
}

archive_preview() {
  bsdtar -tf "$filename" 2>&1 && success="yes" || needs_newline_before_fallback="y"
}

text_preview() {
  awk -v w="$size_x" -v h="$size_y" \
    '{print substr($0, 0, w)} (NR >= h) {exit}' \
    "$filename" && success="yes"
}

fallback_preview() {
  [ -n "$needs_newline_before_fallback" ] && printf '\n'
  file --brief "$filename" | fold -s -w "$size_x"
  printf '\n%s\n' "$mime_description"
}

extension="${filename##*.}"
case "$extension" in
  txt|cfg|conf|properties|log|ini|yaml|toml|py|c|cpp|h|hpp|rs|zig|js|ts|nix|json|sh)
    text_preview;;
  jxl|png|jpeg|jpg|webp|gif)
    image_preview;;
  mkv|mp4|webm)
    video_preview;;
  pdf|djvu)
    pdf_preview;;
  flac|wav|mp3|opus|ape)
    audio_preview;;
  tar|gz|xz|zst|bz2|zstd|tgz|txz|tzst|tzstd|tbz2|zip|rar|jar|rpm)
    archive_preview;;
esac
[ -n "$success" ] && exit

mime_description="$(file --brief --mime -- "$filename")"
case "$mime_description" in
  image/*)
    image_preview;;
  video/*)
    video_preview;;
  application/pdf*)
    pdf_preview;;
  audio/*)
    audio_preview;;
  application/x-tar*|application/zstd*|application/gzip*|application/x-xz*|application/zip*|application/java-archive*|application/x-7z*|application/x-rar*|application/x-bzip2*)
    archive_preview;;
  application/json*)
    text_preview;;
esac
[ -n "$success" ] && exit

case "$mime_description" in
  *charset=binary)
    fallback_preview;;
  *charset=*)
    text_preview;;
esac

#exit $no_cache
exit 0 # if lf uses 500mb of ram uncomment line above

