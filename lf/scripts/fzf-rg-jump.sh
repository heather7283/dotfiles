#!/bin/sh

[ -n "$OLDTERM" ] && export TERM="$OLDTERM"

export FZF_DEFAULT_COMMAND=true
rg_preview_cmd='rg \
    --pretty \
    --context "$((FZF_PREVIEW_LINES / 4))" \
    --smart-case \
    -e {q} {} 2>/dev/null'

rg_find_flags='--files-with-matches --smart-case --hidden '

# my ~/.config/ is one large gitignored git repo (stupid, yeah, but it works)
case "$PWD" in
  (~/.config*) rg_find_flags="${rg_find_flags} --no-ignore-vcs ";;
esac

rg_find_cmd="rg ${rg_find_flags} -e {q} || true"

res="$(fzf \
  --bind "change:reload(${rg_find_cmd})" \
  --preview "${rg_preview_cmd}" \
  --preview-window up \
  --disabled
)"
if [ -z "$res" ]; then exit; fi

if [ -d "$res" ]; then
  cmd="cd"
else
  cmd="select"
  # not needed?
  #if [[ "$(basename "$res")" =~ ^. ]]; then
  #  lf -remote "send $id set hidden true"
  #fi
fi

# no idea what this sed does lol I copied it from lf wiki xdd
res="$(printf '%s' "$res" | sed 's/\\/\\\\/g;s/"/\\"/g')"

lf -remote "send $id $cmd \"$res\""

