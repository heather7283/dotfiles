#!/usr/bin/env bash

die() {
  echo -n "make_dir error" >&2
  if [ -n "$1" ]; then echo -n ": $1" >&2; fi
  exit 1
}

export IFS=$'\t\n'

if [ -z "$TMUX" ]; then
  echo -n "dirname: "
  read -r dirname

  if [ -z "$dirname" ]; then
    die "empty dir name"
  fi
  
  mkdir -p "$dirname"
else
  ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 2 -EE -- bash -c '
    IFS='"$(printf '%q' "$IFS")"'
    
    cd '"$(printf '%q' "$PWD")"'

    echo "dirname:"
    dirname="$(zsh-readline)"
    if [ -z "$dirname" ]; then
      exit 0
    fi

    mkdir -p "$dirname"
  '
fi

