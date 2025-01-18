#!/bin/sh

rec_dir=~/videos/recordings/button/
recorder_pidfile="${rec_dir}/pid"

if [ -f "$recorder_pidfile" ]; then
    exec ~/.config/scripts/gpu-screen-recorder/rec-stop.sh "$@"
else
    exec ~/.config/scripts/gpu-screen-recorder/rec-run.sh "$@"
fi

