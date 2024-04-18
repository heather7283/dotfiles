#!/usr/bin/env bash
# This script is meant to be called by keybind

# Create named pipe udner /tmp
pipe="/tmp/$(mktemp --dry-run cliphist_fzf_foot.XXXXXXXX)"
mkfifo "$pipe"

# Execute 2nd part of this script
hyprctl dispatch exec \[float\;pin\;stayfocused\] -- foot --override colors.background=3D484D ~/.config/scripts/cliphist-fzf/cliphist-fzf-foot.sh "$pipe" >/dev/null

# Read clipboard item from pipe
read -r selected_item < "$pipe"

# If selected item is not an empty string then copy it
if [ -n "$selected_item" ]; then
  echo -n "$selected_item" | cliphist decode | wl-copy
fi

# Cleanup
rm "$pipe"

