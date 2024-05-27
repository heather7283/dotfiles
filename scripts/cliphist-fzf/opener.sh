#!/usr/bin/env bash

item_id="$1"
full_item="$(cliphist list | grep -e "$item_id")"
item="$(echo "$full_item" | cut -d$'\t' -f2)"

# open links in firefox
if [[ "$item" =~ ^http(s)?:// ]]; then
  if pgrep firefox; then
    firefox "$(echo "$full_item" | cliphist decode)"
  else
    hyprctl dispatch exec -- firefox
    firefox "$(echo "$full_item" | cliphist decode)"
  fi
# open images in imv
elif [[ "$item" =~ ^\[\[\ binary\ data\ [1-9][0-9]*\ .iB ]]; then
  tmp_file="/tmp/imv_stdin_$$"
  echo "$full_item" | cliphist decode >"$tmp_file"
  imv -w 'imv-float' "$tmp_file"
  rm "$tmp_file"
# open text in nvim
else
  tmp_file="/tmp/nvim_stdin_$$"
  echo "$full_item" | cliphist decode >"$tmp_file"
  foot --title 'foot-float' -- nvim "$tmp_file"
  rm "$tmp_file"
fi

