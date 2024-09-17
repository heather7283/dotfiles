#!/bin/sh

cclip list | fzf \
  --ignore-case \
  --no-multi \
  --with-nth 3 \
  --delimiter "$(printf '\t')" \
  --scheme history \
  --preview 'exec ~/.config/scripts/cclip-fzf/preview.sh {}' \
  --bind "ctrl-o:become(~/.config/scripts/cclip-fzf/opener.sh {1} {2} {3})" \
  --bind "enter:become(cclip get {1} | wl-copy -t {2})"

