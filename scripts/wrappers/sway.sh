# there is no way to set envvars in sway config
export XDG_CURRENT_DESKTOP=sway

"$real_exe" "$@"
rc="$?"

# there is no way to run commands at shutdown in sway itself so do it here
systemctl --user stop sway-session.target
systemctl --user unset-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK

exit "$rc"

