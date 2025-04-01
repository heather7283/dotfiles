#!/bin/sh

background() {
    (
        trap '' HUP
        "$@" </dev/null >/dev/null 2>&1 &
    )
}

game="$(find ~/games -maxdepth 1 -type d -printf '%f\0' \
        | fzf --read0 \
              --preview 'gd={}; conf=~/games/"$gd"/run-wine-game.conf; cat "$conf"' \
              --bind 'ctrl-o:execute:gd={}; conf=~/games/"$gd"/run-wine-game.conf; nvim "$conf"')"

[ -n "$game" ] && background run-wine-game "$game"

