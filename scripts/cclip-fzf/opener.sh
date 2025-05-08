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

# open links in firefox
case "$preview" in
    (https://*|http://*)
        background browser "$(cclip get "$id")"
        ;;
    (image/*)
        background sh -c ' \
            tmp_file="/tmp/imv_stdin_$$"; \
            cclip get "$1" >"$tmp_file"; \
            imv -w FLOATME "${tmp_file}"; \
            rm "${tmp_file}"; \
        ' 'sh' "$id"
        ;;
    (*)
        background sh -c ' \
            tmp_file="/tmp/nvim_stdin_$$"; \
            cclip get "$1" >"$tmp_file"; \
            foot --title foot-float nvim ${tmp_file}; rm ${tmp_file}; \
            rm "${tmp_file}"; \
        ' 'sh' "$id"
        ;;
esac

