#!/bin/sh

# Some functions....
cleanup() {
    [ -n "$mode_file" ] && rm -f "$mode_file"
    [ -n "$recorder_pidfile" ] && rm -f "$recorder_pidfile"
    [ -n "$recorder_pid" ] && kill -INT "$recorder_pid"
}

die() {
    notify-send -u critical 'Recorder ERROR!' "$1"
    cleanup
    exit 1
}

warn() {
    notify-send 'Recorder warning!' "$1"
}

on_trap() {
    notify-send -u critical 'start-rec.sh was KILLED!' 'This should not have happened.'
    cleanup
    exit 1
}
trap on_trap INT TERM HUP TERM

. ~/.config/scripts/gpu-screen-recorder/config.sh || die "Unable to read config"

# Recording mode can be passed as argv[1]
if [ -z "$1" ]; then
    mode='regular'
else
    case "$1" in
        (regular)
            mode='regular'
            ;;
        (replay)
            mode='replay'
            ;;
        (*)
            die "Unknown mode: $1"
            ;;
    esac
fi

# Check if gpu-screen-recorder is installed
if ! command -v gpu-screen-recorder >/dev/null 2>&1; then
    die 'gpu-screen-recorder is not installed'
fi

# Where the recordings will be saved
rec_dir=~/videos/recordings/button/
rec_dir_videos="${rec_dir}/videos"
if [ ! -d "$rec_dir_videos" ]; then
    mkdir -p "$rec_dir_videos" || die "Unable to create ${rec_dir_videos}"
fi
rec_dir_replays="${rec_dir}/replays"
if [ ! -d "$rec_dir_replays" ]; then
    mkdir -p "$rec_dir_replays" || die "Unable to create ${rec_dir_replays}"
fi

mode_file="${rec_dir}/mode"
echo "$mode" >"$mode_file"

case "$mode" in
    (regular)
        # Use current timestamp as filename
        timestamp="$(date -Is)"
        timestamp="${timestamp%%+*}"
        [ -z "$timestamp" ] && die 'Unable to get timestamp (how???)'
        filename="${rec_dir_videos}/${timestamp}.${FORMAT:-mkv}"

        flock --no-fork --nonblock --conflict-exit-code 101 "$rec_dir" \
            gpu-screen-recorder \
                -w portal \
                -k "${CODEC:-hevc}" \
                -ac "${ACODEC:-opus}" \
                -f "${FPS:-60}" \
                -tune quality \
                -a 'default_output' \
                -a 'default_input' \
                -o "$filename" &
        ;;
    (replay)
        flock --no-fork --nonblock --conflict-exit-code 101 "$rec_dir" \
            gpu-screen-recorder \
                -w portal \
                -k "${CODEC:-hevc}" \
                -ac "${ACODEC:-opus}" \
                -f "${FPS:-60}" \
                -tune quality \
                -r "${REPLAY_BUFFER:-60}" \
                -sc ~/.config/scripts/gpu-screen-recorder/on-save-replay.sh \
                -c ${FORMAT:-mkv} \
                -a 'default_output' \
                -a 'default_input' \
                -o "$rec_dir_replays" &
        ;;
    (*)
        die "Invalid mode: ${mode}"
        ;;
esac

recorder_pid="$!"
recorder_pidfile="${rec_dir}/pid"
echo "$recorder_pid" >"$recorder_pidfile"

chmod a-w "$recorder_pidfile" || warn "Failed to chmod ${recorder_pidfile}"

notify-send 'Started screen recorder' "Mode ${mode}, PID ${recorder_pid}"

# tell waybar to reload recorder button
pkill -SIGRTMIN+8 waybar

wait "$recorder_pid"
child_exitcode="$?"

if [ "$child_exitcode" = 101 ]; then
    die "Failed to take lock on ${rec_dir}"
elif [ "$child_exitcode" -gt 0 ]; then
    warn "Recorder exited non-zero (${child_exitcode})"
else
    if [ -n "$filename" ]; then
        res="$(notify-send -A 'default=Copy path' 'Recorder exited' "${filename}")"
        if [ "$res" = 'default' ]; then
            wl-copy "$filename"
        fi
    else
        notify-send 'Recorder exited' 'Exit code 0'
    fi
fi

cleanup

# tell waybar to reload recorder button
pkill -SIGRTMIN+8 waybar

exit "$child_exitcode"

