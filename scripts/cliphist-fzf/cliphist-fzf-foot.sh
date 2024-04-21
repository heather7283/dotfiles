#!/usr/bin/env bash
# This script runs inside foot window, uses fzf to select clipboard item and sends it to pipe

pipe="$1"

if [ -z "$pipe" ]; then
  echo "No pipe specified, exiting"
  exit 1
fi

cliphist list | fzf \
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
  fi' > "$pipe"

