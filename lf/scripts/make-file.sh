#!/usr/bin/env bash

die() {
  printf '\033[31mmake-file: %s\033[0m' "$@" >&2
  exit 1
}

export IFS=$'\t\n'

if [ -z "$TMUX" ]; then
  echo -n "filename: "
  read -r filename

  if [ -z "$filename" ]; then
    die "empty filename"
  fi

  if [ -e "$filename" ]; then
    die "$filename already exists"
  fi

  touch "$filename"
else
  ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 2 -EE -- bash -c '
    IFS='"$(printf '%q' "$IFS")"'
    
    cd '"$(printf '%q' "$PWD")"'
    
    echo "filename:"
    filename="$(zsh-readline)"
    if [ -z "$filename" ]; then
      exit 0
    fi

    if [ -e "$filename" ]; then
      echo "$filename already exists"
      exit 1
    fi

    touch "$filename"
  '
fi

