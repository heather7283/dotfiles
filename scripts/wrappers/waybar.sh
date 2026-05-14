# To separate e.g. sway-specific config from hyprland-specific config, etc
set -- --config ~/.config/waybar/config."${XDG_CURRENT_DESKTOP:?}".jsonc "$@"

