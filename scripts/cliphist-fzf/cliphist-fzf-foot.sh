#!/usr/bin/env bash

# shell escape nightmare
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
  --bind "ctrl-b:execute-silent(item_raw={}; item=\"\${item_raw#*\$'\t'}\"; if [[ \"\$item\" =~ http(s)?:// ]]; then firefox \"\$item\"; fi)" \
  --preview 'exec ~/.config/scripts/cliphist-fzf/preview.sh {}')"

if [ -n "$selected_entry" ]; then
  echo -n "$selected_entry" | cliphist decode | wl-copy
fi

