#!/usr/bin/env bash

filename="$1"
extension="${filename##*.}"

# first match based on extension
case "$extension" in
  png|jpeg|jpg|jxl|webp|gif)
      exec mvi "$filename" ;;
  mp3|flac|opus|wav|ape)
      exec mpv --no-video "$filename" ;;
  mkv|mp4)
      exec mpv --force-window=immediate "$filename" ;;
  webm) # can be either video or music, so dont force window
      exec mpv "$filename" ;;
  djvu|pdf)
      exec zathura "$filename" ;;
  docx|odt)
      exec libreoffice "$(realpath "$filename")" ;;
  html)
      exec browser "$filename" ;;
esac

# match based on mime type
mime_description=$(file --brief --mime -- "$filename")
case "$mime_description" in
  image/*)
    exec mvi "$filename" ;;
  video/*)
    exec mpv --force-window=immediate "$filename" ;;
  audio/*)
    exec mpv --no-video "$filename" ;;
  application/vnd.openxmlformats-officedocument.wordprocessingml.document*)
    exec libreoffice "$(realpath "$filename")" ;;
  application/pdf*)
    exec zathura "$filename" ;;
esac

if [[ "$mime_description" =~ charset= ]] && [[ ! "$mime_description" =~ charset=binary ]]; then
  exec "${EDITOR:-vi}" "$filename"
fi

~/.config/lf/scripts/tmux-popup.sh -h 2 -- \
    sh -c "printf '\033[31;1mUnknown type:\033[0m\n  ${mime_description}'"

