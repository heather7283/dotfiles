#!/usr/bin/env bash

# shell escape nightmare
selected_entry="$(cliphist list | fzf \
  --ignore-case \
  --no-multi \
  --no-clear \
  --with-nth 2 \
  --delimiter $'\t' \
  --bind "ctrl-o:become(hyprctl dispatch exec -- ~/.config/scripts/cliphist-fzf/opener.sh {1})" \
  --preview 'exec ~/.config/scripts/cliphist-fzf/preview.sh {}')"

if [ -n "$selected_entry" ]; then
  echo -n "$selected_entry" | cliphist decode | wl-copy
fi

