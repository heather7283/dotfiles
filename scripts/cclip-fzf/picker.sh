#!/bin/sh

if [ "$1" = 'tagged' ]; then
    become_cmd='~/.config/scripts/cclip-fzf/picker.sh'
    list_cmd='cclip list -t rowid,mime_type,timestamp,tag'
else
    become_cmd='~/.config/scripts/cclip-fzf/picker.sh tagged'
    list_cmd='cclip list rowid,mime_type,timestamp,preview'
fi
export FZF_DEFAULT_COMMAND="$list_cmd"

fzf \
  --ignore-case \
  --no-multi \
  --with-nth 4 \
  --delimiter '	' \
  --scheme history \
  --no-clear \
  --preview 'exec ~/.config/scripts/cclip-fzf/previewer.sh {}' \
  --preview-window right,wrap \
  --bind 'focus:transform-preview-label:date -d @{3} "+%a, %d %b %Y %H:%M:%S %Z"' \
  --preview-label-pos bottom \
  --bind "ctrl-o:become(~/.config/scripts/cclip-fzf/opener.sh {1} {2} {4})" \
  --bind "ctrl-e:execute(cclip get {1} | nvim)+reload(${list_cmd})" \
  --bind "ctrl-x:execute-silent(cclip delete -s {1})+reload(${list_cmd})" \
  --bind "ctrl-t:execute(~/.config/scripts/cclip-fzf/tag.sh {1})+reload(${list_cmd})" \
  --bind "ctrl-space:become(${become_cmd})" \
  --bind "ctrl-r:reload(${list_cmd})" \
  --bind "enter:become(cclip copy {1})"

