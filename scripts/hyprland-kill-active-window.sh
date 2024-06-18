#!/usr/bin/env bash

addr="$(hyprctl activewindow -j | jq -r ".address")"
IFS=$'\t' read -r pid initial_class < <(hyprctl clients -j | jq -r ".[] | select(.address == \""$addr"\") | ( .pid, .initialClass )" | tr '\n' '\t')

# prevent killing foot server
if [[ "$initial_class" = *foot* ]]; then
  hyprctl dispatch closewindow address:"$addr"
  exit
fi

# if process only has 1 window, close it and then force kill the process after 3 seconds
if [ "$(hyprctl clients -j | jq -r "[.[] | select(.pid == $pid)] | length")" -le 1 ]; then
  hyprctl dispatch closewindow address:"$addr"

  sleep 3

  # some windows might open confirmation popups before closing, check for this case
  if [ "$(hyprctl clients -j | jq -r "[.[] | select(.pid == $pid)] | length")" -le 1 ]; then
    kill -TERM "$pid"
  fi
# if process has multiple windows, just close one of them
else
  hyprctl dispatch closewindow address:"$addr"
fi

