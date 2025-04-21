# if already running in hyprland...
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    exec "${real_exe}" --config ~/.config/hypr/nested.conf "$@"
fi

