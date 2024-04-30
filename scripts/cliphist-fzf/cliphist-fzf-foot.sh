#!/usr/bin/env bash

selected_entry="$(cliphist list | fzf \
  -i \
  --no-multi \
  --bind 'tab:up' \
  --cycle \
  --preview-window border-sharp \
  --info hidden \
  --no-scrollbar \
  --no-clear \
  --with-nth 2 \
  --delimiter $'\t' \
  --preview 'exec ~/.config/scripts/cliphist-fzf/preview.sh {}')"

if [ -n "$selected_entry" ]; then
  echo -n "$selected_entry" | cliphist decode | wl-copy
fi

