#!/usr/bin/env bash

level1=(
  "[S]earch the web"$'\t'"~/.config/scripts/firefox-web-search.sh"
  "Browse [7]tv emotes"$'\t'"~/.config/scripts/7tv-browser.sh"
  "[T]ranslate text"$'\t'"~/.config/scripts/deeplx-translator.sh"
)

choose() {
  local -n arr="$1"

  for elem in "${arr[@]}"; do
    echo "$elem";
  done | fzf \
    --delimiter $'\t' \
    --with-nth 1 \
    --nth 1 \
    --disabled \
    --multi \
    --sync \
    --bind 'load:select-all' \
    --bind 'change:transform:
      query={q};
      if [ "${#query}" -gt 1 ];
        query="${query:(-1)}"
        then echo -n "change-query($query)";
        plus_needed=1;
      fi;

      trigger="\[${query}\]";
      match="$(grep -m1 -inoe "$trigger" {+f})";
      if [ -n "$match" ]; then
        n="${match%%:*}";
        if [ "$plus_needed" = 1 ]; then echo -n "+"; fi;
        echo "deselect-all+pos($n)+select+accept";
      fi' \
    --bind 'enter:deselect-all+select+accept' \
    --bind 'double-click:deselect-all+select+accept' \
    --preview 'chafa \
      --format sixels \
      --view-size ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} \
      --scale max \
      --align center,center \
      ~/sticker.webp' \
    --preview-window 'border-none' \
    --no-info \
    --no-scrollbar \
    --prompt '? ' \
    --marker=' ' \
    --reverse
}

# hide cursor
#printf "\033[?25l" >/dev/tty; 

IFS=$'\t' read -r description script_path < <(choose level1)
exec "$script_path"

