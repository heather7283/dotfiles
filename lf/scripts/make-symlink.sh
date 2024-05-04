#!/usr/bin/env bash

die() {
  echo -n "make_symlink error" >&2
  if [ -n "$1" ]; then echo -n ": $1" >&2; fi
  exit 1
}

export IFS=$'\t\n'

if [ -z "$TMUX" ]; then
  echo -n "link name: "
  read -r linkname

  if [ -z "$linkname" ]; then
    die "empty link name"
  fi

  echo -n "link target: "
  read -r linktgt

  if [ -z "$linktgt" ]; then
    die "empty link target"
  fi

  ln -s "$linktgt" "$linkname"
else
  ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 4 -EE -- bash -c '
    IFS='"$(printf '%q' "$IFS")"'
    
    cd '"$(printf '%q' "$PWD")"'
    
    echo "link name:"
    linkname="$(zsh-readline)"
    if [ -z "$linkname" ]; then
      exit 0
    fi

    echo "link target:"
    linktgt="$(zsh-readline)"
    if [ -z "$linktgt" ]; then
      echo "Empty link target"
      exit 1
    fi

    ln -s "$linktgt" "$linkname"
  '
fi

