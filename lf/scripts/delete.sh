#!/usr/bin/env bash

die() {
  echo -n "delete" >&2
  if [ -n "$1" ]; then echo -n ": $1"; fi
  echo
  exit 1
}

IFS=$'\n'

if [ -z "$fx" ]; then die "no files selected"; fi
if [ ! -d ~/.trash ]; then mkdir ~/.trash/ || die "can't create trash dir"; fi

file_count="$(echo "$fx" | wc -l)"
if [ "$file_count" = 1 ]; then
  dir="$(date '+%Y-%m-%dT%H:%M:%S')"
  if [ -z "$dir" ]; then die "failed to get current time"; fi
  mkdir ~/.trash/$dir || die "failed to create $dir dir in trash"
  mv -v --backup=numbered -t ~/.trash/$dir -- $fx

  exit 0
fi

if [ -z "$TMUX" ]; then
  echo -n "delete $file_count files? [y/N] "
  read -r answer
  if echo -n "$answer" | grep -qEe '^y$|^Y$|^yes$|^Yes$'; then :; else die "aborted by user"; fi

  dir="$(date '+%Y-%m-%dT%H:%M:%S')"
  if [ -z "$dir" ]; then die "failed to get current time"; fi
  mkdir ~/.trash/$dir || die "failed to create $dir dir in trash"

  mv -t --backup=numbered ~/.trash/$dir -- $fx
else
  fifo_up="$(mktemp --dry-run /tmp/lf-delete.XXXXXX.up)"
  mkfifo "$fifo_up" || die "failed to create fifo $fifo_up"
  echo "$fx" >"$fifo_up" &

  ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 70% -- bash -c '
    IFS=$'\''\n'\''
    
    fifo_up="$0"
    fx="$(cat "$fifo_up")"

    file_count="$1"
    echo -n "delete $file_count files? [y/N] "
    read answer
    if echo -n "$answer" | grep -qEe "^y$|^Y$|^yes$|^Yes$"; then
      dir="$(date "+%Y-%m-%dT%H:%M:%S")"
      if [ -z "$dir" ]; then echo "failed to get current time" >&2; exit 1; fi
      mkdir ~/.trash/$dir || { echo "failed to create $dir dir in trash"; exit 1; }

      mv -v --backup=numbered -t ~/.trash/$dir -- $fx
    fi
  ' "$fifo_up" "$file_count"
  
  rm "$fifo_up"
fi


