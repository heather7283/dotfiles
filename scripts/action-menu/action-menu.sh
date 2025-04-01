#!/bin/sh

background() {
    (
        trap '' HUP
        "$@" </dev/null >/dev/null 2>&1 &
    )
}

tab='	'
newline='
'

items="\
Internet [s]earch${tab}~/.config/scripts/firefox-web-search.sh
[7]tv browser${tab}~/.config/scripts/7tv-browser/7tv-browser.sh
[t]ranslator${tab}~/.config/scripts/deeplx-translator/deeplx-translator.sh
[e]moji picker${tab}~/.config/scripts/emoji-picker/picker.sh
[u]nicode picker${tab}~/.config/scripts/unicode-picker/picker.sh
[b]rowser history${tab}~/.config/scripts/firefox-history-fzf/firefox-history-fzf.sh
Application [r]unner${tab}~/.config/scripts/drun-fzf/drun-fzf.sh
[c]lipboard history${tab}~/.config/scripts/cclip-fzf/picker.sh
[m]PRIS control${tab}~/.config/scripts/mpris-control/player-control.sh
[a]udio control${tab}pipemixer
[q]alculate${tab}tmux new-session qalc
Toggle screen [R]ecording${tab}background ~/.config/scripts/gpu-screen-recorder/rec-toggle.sh"

change_script='
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
'

choose() {
    echo "$items" | fzf \
        --delimiter "$tab" \
        --with-nth 1 \
        --nth 1 \
        --accept-nth 2 \
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

script="$(choose level1)"
eval "$script"

