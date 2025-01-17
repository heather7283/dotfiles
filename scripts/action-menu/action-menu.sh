#!/usr/bin/env bash

level1=(
  "Internet [s]earch"$'\t'"~/.config/scripts/firefox-web-search.sh"
  "[7]tv browser"$'\t'"~/.config/scripts/7tv-browser/7tv-browser.sh"
  "[t]ranslator"$'\t'"~/.config/scripts/deeplx-translator/deeplx-translator.sh"
  "[e]moji picker"$'\t'"~/.config/scripts/emoji-picker/picker.sh"
  "[u]nicode picker"$'\t'"~/.config/scripts/unicode-picker/picker.sh"
  "[b]rowser history"$'\t'"~/.config/scripts/firefox-history-fzf/firefox-history-fzf.sh"
  "Application [r]unner"$'\t'"~/.config/scripts/drun-fzf/drun-fzf.sh"
  "[c]lipboard history"$'\t'"~/.config/scripts/cclip-fzf/picker.sh"
  "[m]PRIS control"$'\t'"~/.config/scripts/mpris-control/player-control.sh"
  "[a]udio control"$'\t'"pulsemixer"
  "[q]alculate"$'\t'"tmux new-session qalc"
)

change_script="$(cat<<'EOF'
query={q};

if [ "${#query}" -gt 1 ]; then
  query="${query: -1:1}";
  printf "change-query(${query})";
  plus_needed=1;
fi;

trigger="\[${query}\]";
match="$(grep -m1 -noe "$trigger" {+f})";
if [ -n "$match" ]; then
  line="${match%%:*}";
  if [ "$plus_needed" = 1 ]; then echo -n "+"; fi;
  printf "deselect-all+pos(${line})+select+accept";
fi
EOF
)"

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
    --with-shell 'bash -c' \
    --bind 'load:select-all' \
    --bind "change:transform:${change_script}" \
    --bind 'enter:deselect-all+select+accept' \
    --bind 'double-click:deselect-all+select+accept' \
    --preview 'cat ~/.config/scripts/action-menu/art.txt' \
    --preview-window 'border-none' \
    --no-info \
    --no-scrollbar \
    --prompt '? ' \
    --marker=' ' \
    --reverse
}

IFS=$'\t' read -r description script_path < <(choose level1)
exec $script_path

