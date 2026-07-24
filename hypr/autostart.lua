hl.on("hyprland.start", function()
  hl.exec_cmd([[
    systemctl --user import-environment \
      DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
    systemctl --user start my-graphical-session.target
  ]])

  hl.exec_cmd([[
    pgrep --exact "tmux: server" && attach=attach
    exec foot --app-id foot-tmux --term foot-extra tmux $attach
  ]])

  hl.exec_cmd("hyprctl setcursor Adwaita 20")
  hl.exec_cmd("hyprctl switchxcblayout all 0")
end)

hl.on("hyprland.shutdown", function()
  hl.exec_cmd([[
    systemctl --user stop my-graphical-session.target
    systemctl --user unset-environment \
      DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP HYPRLAND_INSTANCE_SIGNATURE
  ]])
end)

