#!/bin/sh

die() {
    notify-send -u critical 'Failed to stop recording!' "$1"
    exit 1
}

rec_dir=~/videos/recordings/button/
recorder_pidfile="${rec_dir}/pid"

[ ! -r "$recorder_pidfile" ] && die "${recorder_pidfile} does not exist or no read perms"

recorder_pid="$(cat "$recorder_pidfile")"
[ -z "$recorder_pid" ] && die "Empty ${recorder_pidfile}"

kill -INT "$recorder_pid"

