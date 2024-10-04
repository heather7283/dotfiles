#!/bin/sh

list_cmd="cclip list"
export FZF_DEFAULT_COMMAND="$list_cmd"

fzf \
  --ignore-case \
  --no-multi \
  --with-nth 3 \
  --delimiter "$(printf '\t')" \
  --scheme history \
  --no-clear \
  --preview 'exec ~/.config/scripts/cclip-fzf/previewer.sh {}' \
  --bind "ctrl-o:become(~/.config/scripts/cclip-fzf/opener.sh {1} {2} {3})" \
  --bind "ctrl-x:execute-silent(cclip delete -s {1})+reload(${list_cmd})" \
  --bind "ctrl-r:reload(${list_cmd})" \
  --bind "enter:become(cclip get {1} | wl-copy -t {2}; sleep 0.05)"
  # DO NOT REMOVE sleep 0.05 EVERYTHING BREAKS WITHOUT IT

