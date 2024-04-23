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
  --preview \
  'if echo {} | grep -q binary\ data; \
    then echo {} | cliphist decode | chafa \
      --format sixels \
      --align center \
      --optimize 9 \
      --view-size ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}; \
    else echo {} | cliphist decode | sed -e "s/.\{${FZF_PREVIEW_COLUMNS}\}/&\n/g"; \
  fi')"

if [ -n "$selected_entry" ]; then
  echo -n "$selected_entry" | cliphist decode | wl-copy
fi

