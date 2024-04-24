#!/usr/bin/env bash

IFS=$'\t' read -r name filename filepath < <(~/.config/scripts/drun-fzf/parse-desktop-files.py | fzf \
  --no-clear \
  --with-nth 1..2 \
  --nth 1..2 \
  --delimiter $'\t')

if [ -z "$filepath" ]; then
  exit 1
fi

~/.config/scripts/run-desktop-file.sh "$filepath"

