#!/usr/bin/env bash

item_raw="$1"
item="${item_raw#*$'\t'}"

if [[ "$item" =~ binary\ data ]]; then
  echo -n "$item_raw" | cliphist decode | chafa \
    --format sixels \
    --align center \
    --optimize 9 \
    --view-size ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES};
elif [[ "$item" =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
  item="${item/#\#/}"
  r="$((16#${item:0:2}))"
  g="$((16#${item:2:2}))"
  b="$((16#${item:4:2}))"
  echo "#$item"
  echo "$r $g $b"
  printf "\033[48;2;${r};${g};${b}m %*s \033[0m" "$FZF_PREVIEW_COLUMNS" ""
else
  echo -n "$item_raw" | cliphist decode | sed -e "s/.\{${FZF_PREVIEW_COLUMNS}\}/&\n/g";
fi

