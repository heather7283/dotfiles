#!/usr/bin/env bash

item_raw="$1"
item="${item_raw#*$'\t'}"

# images
if [[ "$item" =~ binary\ data ]]; then
  echo -n "$item_raw" | cliphist decode | chafa \
    --format sixels \
    --align center \
    --scale max \
    --optimize 9 \
    --view-size ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES};
# hex colors
elif [[ "$item" =~ ^(#|0x)?[0-9a-fA-F]{6,8}$ ]]; then
  item="${item/#\#/}"
  r="$((16#${item:0:2}))"
  g="$((16#${item:2:2}))"
  b="$((16#${item:4:2}))"
  echo "#$item"
  echo "$r $g $b"
  printf "\033[48;2;${r};${g};${b}m %*s \033[0m" "$FZF_PREVIEW_COLUMNS" ""
# youtube
elif [[ "$item" =~ ^https:\/\/www.youtube.com\/watch\?v= ]]; then
  url="${item#https://www.youtube.com/watch?v=}"
  url="${url%&*}"
  curl --no-progress-meter "https://img.youtube.com/vi/$url/3.jpg" | chafa \
    -f sixels \
    --align center \
    --scale max \
    --optimize 9 \
    --view-size ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} \
    --scale max
# youtube
elif [[ "$item" =~ ^https:\/\/youtu.be\/ ]]; then
  url="${item#https://youtu.be/}"
  curl --no-progress-meter "https://img.youtube.com/vi/$url/3.jpg" | chafa \
    -f sixels \
    --align center \
    --scale max \
    --optimize 9 \
    --view-size ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} \
    --scale max
# fallback
else
  echo -n "$item_raw" | cliphist decode | sed -e "s/.\{${FZF_PREVIEW_COLUMNS}\}/&\n/g";
fi

