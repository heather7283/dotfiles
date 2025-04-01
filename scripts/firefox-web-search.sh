#!/bin/sh

background() {
    (
        trap '' HUP
        "$@" </dev/null >/dev/null 2>&1 &
    )
}

tmpfile="$(mktemp)"
printf "Search the Internet for...\n" >"$tmpfile"

nvim \
    -c 'nnoremap <ESC> :q!<CR>' \
    -c 'nnoremap <CR> :wq<CR>' \
    -c 'call feedkeys("o")' \
    "$tmpfile"
query="$(sed -e '1d;/^$/d;s/ /+/g' "$tmpfile" | tr '\n' '+')"

if [ -n "$query" ]; then
    engine='https://duckduckgo.com/?t=ffab&q='
    background browser "${engine}${query}"
fi

rm "$tmpfile"

