#!/bin/sh

id="$1"
tag="$(cclip get "$id" tag)"

f="$(mktemp -t)"
[ -z "$f" ] && exit 1
echo "$tag" >"$f"

cleanup() {
    rm "$f"
    # beam cursor
    printf '\033[6 q' >/dev/tty
}
trap cleanup QUIT INT TERM HUP EXIT

ask() {
    local ans
    read -p "${1} " -r ans
    case "$ans" in
        (y|Y|yes|Yes|YES) return 0 ;;
        (*) return 1 ;;
    esac
}

rc=1
while [ ! "$rc" -eq 0 ]; do
    nvim "$f" -c 'nnoremap <ESC> :q!<CR>' -c 'nnoremap <CR> :wq<CR>' -c 'call feedkeys("i")'

    new_tag="$(cat "$f")"

    if [ -z "$new_tag" ] && ask "Delete tag?"; then
        cclip tag -d "$id"
        rc="$?"
    elif [ "$new_tag" != "$tag" ]; then
        cclip tag "$id" "$new_tag"
        rc="$?"
    fi

    if [ ! "$rc" -eq 0 ]; then
        if ! ask "Failed to insert/delete, retry?"; then
            break
        fi
    fi
done

