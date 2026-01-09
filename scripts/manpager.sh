#!/bin/sh

f="${1:-/dev/stdin}"

if pager="$(command -v nvim)"; then
    set -- "$pager" -c ':set signcolumn=no' -c 'Man!'
elif pager="$(command -v less)"; then
    set -- "$pager"
fi

# remove fancy qoutes that make my shell shit itself when I copy commands from man pages
if [ -z "$pager" ]; then
    sed -e "s/[‘’]/'/g;"'s/[“”]/"/g' "$f"
else
    sed -e "s/[‘’]/'/g;"'s/[“”]/"/g' "$f" | "$@"
fi

