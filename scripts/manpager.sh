#!/bin/sh

f="${1:-/dev/stdin}"

if pager="$(command -v nvim)"; then
    set -- "$pager" -c ':set signcolumn=no' -c 'Man!'
elif pager="$(command -v less)"; then
    set -- "$pager"
fi

# remove fancy characters that make my shell shit itself when I copy commands from man pages
process() {
    sed -e "s/[‘’]/'/g" -e 's/[“”]/"/g' -e 's/˜/~/g' -e 's/ˆ/^/g' "$1"
}

if [ -z "$pager" ]; then
    process "$f"
else
    process "$f" | "$@"
fi

