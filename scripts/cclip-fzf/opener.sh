#!/bin/sh

background() {
    (
        trap '' HUP
        "$@" </dev/null >/dev/null 2>&1 &
    )
}

id="$1"
mime="$2"
preview="$3"

case "$mime" in
    (image/*)
        background sh -c ' \
            cclip get "$1" \
            | mvi --wayland-app-id=FLOATME --force-window=immediate --autofit=50% -; \
        ' 'sh' "$id"
        exit
        ;;
esac

case "$preview" in
    (https://*|http://*)
        background browser "$(cclip get "$id")"
        exit
        ;;
    (*)
        exec sh -c 'cclip get "$1" | nvim' 'sh' "$id"
        exit
        ;;
esac

