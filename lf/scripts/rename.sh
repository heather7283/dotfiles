#!/usr/bin/env bash

die() {
  echo -n "rename error" >&2
  if [ -n "$1" ]; then echo -n ": $1" >&2; fi
  exit 1
}

export IFS=$'\t\n'

if [ -z "$f" ]; then die "no file selected"; fi
file="$f"

if [ -z "$TMUX" ]; then
  echo -n "new name: "
  read -r new_name
  if [ -z "$new_name" ]; then
    die "empty new name"
  fi

  dir_name="$(dirname "$file")"
  mv -v "$file" "$dir_name/$new_name"
else
  #fifo_up="$(mktemp --dry-run /tmp/lf-rename.XXXXXX.up)"
  #mkfifo "$fifo_up" || die "failed to create fifo $fifo_up"
  #echo "$file" >"$fifo_up" &

  ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 2 -E -- bash -c '
    IFS='"$(printf '%q' "$IFS")"'
    #fifo_up='"$(printf '%q' "$fifo_up")"'
    file='"$(printf '%q' "$file")"'
    
    cd '"$(printf '%q' "$PWD")"'
    
    #file="$(cat "$fifo_up")"

    old_name="$(basename "$file")"
    dir_name="$(dirname "$file")"

    echo "enter new filename:"

    new_name="$(zsh-readline --string "$old_name" --mode normal)"
    if [ -z "$new_name" ]; then
      echo "Empty new name"
      exit 1
    fi
    if [ "$new_name" = "$old_name" ]; then
      echo "New name and old name are the same"
      exit 0
    fi
    
    mv -v "$file" "$dir_name/$new_name"
  '
  
  #rm "$fifo_up"
fi


