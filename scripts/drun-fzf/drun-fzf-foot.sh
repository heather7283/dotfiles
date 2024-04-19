#!/usr/bin/env bash

IFS=$'\t' read -r name filename < <(~/.config/scripts/drun-fzf/parse-desktop-files.py | fzf \
  --no-clear \
  --with-nth 1 \
  --nth 1 \
  --delimiter $'\t')

if [ -z "$filename" ]; then
  exit 1
fi

~/.config/scripts/run-desktop-file.sh "$filename"

