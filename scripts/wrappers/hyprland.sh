# if already running in hyprland...
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    set -- --config ~/.config/hypr/nested.conf "$@"
fi

# for some reason hyprshit doesn't do this itself
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

