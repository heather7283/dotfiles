local hlc = require('hlc')
local table = require('table')
local math = require('math')

local super_bind = function(keys, action, opts)
  hl.bind("SUPER + " .. keys, action, opts)
end

super_bind("T", hl.dsp.exec_cmd([[
  pgrep --exact "tmux: server" && attach=attach
  exec foot --app-id foot-tmux --term foot-extra tmux $attach
]]))
super_bind("SHIFT + T", hl.dsp.exec_raw("exec foot --app-id foot-tmux tmux new-session"))

local exec_in_popup = function(cmd)
  return hl.dsp.exec_raw("foot-popup " .. cmd)
end

super_bind("A", exec_in_popup("pipemixer"))
super_bind("R", exec_in_popup("~/.config/scripts/drun-fzf/drun-fzf.sh"))
super_bind("C", exec_in_popup("~/.config/scripts/cclip-fzf/picker.sh"))
super_bind("B", exec_in_popup("~/.config/scripts/firefox-history-fzf/firefox-history-fzf.sh"))
super_bind("D", exec_in_popup("~/.config/scripts/action-menu/action-menu.sh"))

--super_bind("Q", hl.dsp.exec_raw("~/.config/scripts/hyprland-kill-active-window.sh"))
super_bind("Q", hl.dsp.window.close())
super_bind("SHIFT + Q", hl.dsp.window.signal({ signal = 9, window = "activewindow" }))
super_bind("O", hl.dsp.window.float())
super_bind("P", hl.dsp.window.pin())
super_bind("F", hl.dsp.window.fullscreen({ mode = "maximized" })) -- maximize (keep panel)
super_bind("SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- actual fullscreen

super_bind("mouse_down", function()
  hlc.cursor.zoom_factor = math.max(1, hl.get_config("cursor.zoom_factor") / 1.5)
end) -- zoom in
super_bind("mouse_up", function()
  hlc.cursor.zoom_factor = hl.get_config("cursor.zoom_factor") * 1.5
end) -- zoom out
super_bind("mouse:274", function()
  hlc.cursor.zoom_factor = 1
end) -- wheel press

super_bind("S", hl.dsp.exec_cmd([[
  grim - \
  | tee ~/pictures/sshots/"$(date --iso-8601=ns)".png \
  | wl-copy -t "image/png"
]]))
super_bind("SHIFT + S", hl.dsp.exec_cmd([[
  frzscr -c sh -c 'grim -g "$(slurp -d)" -' \
  | tee ~/pictures/sshots/"$(date --iso-8601=ns)".png \
  | wl-copy -t "image/png"
]]))
super_bind("CTRL + S", hl.dsp.exec_cmd([[
  frzscr -c sh -c 'grim -g "$(slurp -d)" -' \
  | ssedit -f png \
  | wl-copy -t "image/png"
]]))

super_bind("U", hl.dsp.exec_raw("hyprpicker -a -f hex"))

-- Cycle through open windows
super_bind("N", hl.dsp.window.cycle_next())

-- Scroll through existing workspaces
super_bind("K", hl.dsp.focus({ workspace = "r+1" }))
super_bind("J", hl.dsp.focus({ workspace = "r-1" }))
super_bind("SHIFT + mouse:276", hl.dsp.focus({ workspace = "r+1" }))
super_bind("SHIFT + mouse:275", hl.dsp.focus({ workspace = "r-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
super_bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
super_bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- groupbar binds
super_bind("G", hl.dsp.group.toggle())
super_bind("SHIFT + G", hl.dsp.window.move({ out_of_group = true }))
super_bind("bracketright", hl.dsp.group.next())
super_bind("bracketleft", hl.dsp.group.prev())
super_bind("mouse:276", hl.dsp.group.next())
super_bind("mouse:275", hl.dsp.group.prev())

-- Switch workspaces with mainMod + [9-0]
-- Move active window to a workspace with mainMod + SHIFT + [9-0]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    super_bind(key, hl.dsp.focus({ workspace = i}))
    super_bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Audio control with pactl
super_bind("XF86AudioRaiseVolume", hl.dsp.exec_raw("wpctl set-volume @DEFAULT_SINK@ 5%+"), {
  repeating = true
})
super_bind("XF86AudioLowerVolume", hl.dsp.exec_raw("wpctl set-volume @DEFAULT_SINK@ 5%-"), {
  repeating = true
})
hl.bind("XF86AudioMute", hl.dsp.exec_raw("wpctl set-volume @DEFAULT_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_raw("wpctl set-volume @DEFAULT_SOURCE@ toggle"))
-- VoidSymbol is capslock
hl.bind("VoidSymbol", hl.dsp.exec_raw("wpctl set-mute @DEFAULT_SOURCE@ toggle"))

-- Backlight control
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_raw("brightnessctl set 10%+"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_raw("brightnessctl set 10%-"), { repeating = true })

-- Turn display off
-- (XF86ScreenSaver doesn't work for some reason so we use the keycode)
hl.bind("code:160", function()
  hl.timer(function()
    hl.dispatch(hl.dsp.dpms({ action = "disable" }))
  end, { timeout = 500, type = "oneshot" })
end)

-- Bind F10 key to toggle player play/pause
super_bind("XF86TouchpadToggle", hl.dsp.exec_raw("playerctl play-pause"))

super_bind("KP_Multiply", hl.dsp.exec_raw("pkill -USR1 gpu-scree"))

super_bind("P", hl.dsp.window.signal({ signal = 19 }))
super_bind("SHIFT + P", hl.dsp.window.signal({ signal = 18 }))

local keyboard_colors = {
  default = { 255, 255, 255 },
  cursor = { 255, 0, 255 },
  vi = { 0, 0, 255 },
}

local set_keyboard_color = function(r, g, b)
  hl.dispatch(hl.dsp.exec_cmd("~/.config/scripts/kbd-backlight-set.sh "..r.." "..g.." "..b))
end

-- ========== mouse emulation submap ==========
super_bind("M", function()
  set_keyboard_color(table.unpack(keyboard_colors.cursor))
  hl.dispatch(hl.dsp.submap("cursor"))
end)

hl.define_submap("cursor", function()
  -- Jump cursor to a position
  --bind = , g, exec, hyprctl dispatch submap reset && wl-kbptr && hyprctl dispatch submap cursor

  -- Cursor movement
  --binde = , j, hl.dsp.exec_raw("wlrctl pointer move 0 20
  --binde = , k, hl.dsp.exec_raw("wlrctl pointer move 0 -20
  --binde = , l, hl.dsp.exec_raw("wlrctl pointer move 20 0
  --binde = , h, hl.dsp.exec_raw("wlrctl pointer move -20 0
  --binde = SHIFT, j, hl.dsp.exec_raw("wlrctl pointer move 0 10
  --binde = SHIFT, k, hl.dsp.exec_raw("wlrctl pointer move 0 -10
  --binde = SHIFT, l, hl.dsp.exec_raw("wlrctl pointer move 10 0
  --binde = SHIFT, h, hl.dsp.exec_raw("wlrctl pointer move -10 0

  -- Left button
  --bind = , s, hl.dsp.exec_raw("wlrctl pointer click right
  -- Middle button
  --bind = , d, hl.dsp.exec_raw("wlrctl pointer click middle
  -- Right button
  --bind = , f, hl.dsp.exec_raw("wlrctl pointer click left

  --bindi = , catchall, hl.dsp.exec_raw(" # noop

  hl.bind("escape", function()
    set_keyboard_color(table.unpack(keyboard_colors.default))
    hl.dispatch(hl.dsp.submap("reset"))
  end)
end)

-- ========== vi keybinds emulation submap ==========
super_bind("I", function()
  set_keyboard_color(table.unpack(keyboard_colors.vi))
  hl.dispatch(hl.dsp.submap("vi"))
end)

hl.define_submap("vi", function()
  hl.bind("h", hl.dsp.send_shortcut({ mods = "", key = "Left" }), { repeating = true })
  hl.bind("j", hl.dsp.send_shortcut({ mods = "", key = "Down" }), { repeating = true })
  hl.bind("k", hl.dsp.send_shortcut({ mods = "", key = "Up" }), { repeating = true })
  hl.bind("l", hl.dsp.send_shortcut({ mods = "", key = "Right" }), { repeating = true })

  hl.bind("escape", function()
    set_keyboard_color(table.unpack(keyboard_colors.default))
    hl.dispatch(hl.dsp.submap("reset"))
  end)
end)

