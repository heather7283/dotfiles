#!/bin/sh

set -eu

id="$1"
tag="$(cclip get "$id" tag)"

f="$(mktemp -t)"
[ -z "$f" ] && exit 1
echo "$tag" >"$f"

nvim "$f" -c 'nnoremap <ESC> :q!<CR>' -c 'nnoremap <CR> :wq<CR>' -c 'call feedkeys("i")'

new_tag="$(cat "$f")"

if [ "$new_tag" != "$tag" ]; then
    if [ -z "$new_tag" ]; then
        cclip tag -d "$id"
    else
        cclip tag "$id" "$new_tag"
    fi
fi

rm "$f"
printf '\033[6 q' >/dev/tty

