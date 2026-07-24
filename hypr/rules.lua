local hlc = require('hlc')

-- Explicitly center all floating windows (except xwayland because it breaks shit)
hl.window_rule({
  match = { float = true, xwayland = false },
  center = true,
})

-- Firefox Picture-in-Picture
hl.window_rule({
  match = { initial_title = "^Picture-in-Picture$" },
  float = true,
  pin = true,
  keep_aspect_ratio = true,
  size = { "30%", "30%" },
  suppress_event = "fullscreen maximize",
})

-- Firefox launches on the 2nd workspace
hl.window_rule({
  match = { initial_title = "^Mozilla Firefox$", initial_class = "^firefox(-esr|-bin)?$" },
  tile = true,
  workspace = "2 silent",
})
-- Vesktop and telegram on the 3rd
hl.window_rule({
  match = { initial_class = "^discord$" },
  workspace = "3 silent",
})
hl.window_rule({
  match = { initial_class = "^org.telegram.desktop$" },
  workspace = "3 silent",
})

-- Make telegram media viewer floating and fullscreen it
hl.window_rule({
  match = { initial_class = "^org.telegram.desktop$", title = "^Media viewer$" },
  float = true,
  fullscreen_state = "1 1",
})

-- Ripdrag & dragon
hl.window_rule({match = { initial_class = "^it.catboy.ripdrag$" }, pin = true })
hl.window_rule({match = { initial_class = "^dragon$" }, pin = true })

-- Every window with FLOATME class will be floated
hl.window_rule({match = { initial_class = "^FLOATME$" }, float = true })

-- prevent certain apps from fullscreening themselves
hl.window_rule({
  match = { initial_class = "^vesktop$" },
  suppress_event = "fullscreen maximize"
})
hl.window_rule({
  match = { initial_class = "^libreoffice.*$" },
  suppress_event = "fullscreen maximize"
})
hl.window_rule({
  match = { xwayland = true },
  suppress_event = "fullscreen maximize activate activatefocus"
})

hl.window_rule({
  match = { initial_class = "^xdg-desktop-portal-termfilechooser$" },
  size = { "(monitor_w*0.6)", "(monitor_h*0.8)" },
  float = true,
  center = true,
})

hl.window_rule({
  match = { initial_class = "^ssedit$" },
  size = { "(monitor_w*0.6)", "(monitor_h*0.8)" },
  float = true,
  center = true,
})

-- I LOVE HYPRLAND LETS FUCKING GOOOOOOOOOOOOOOOOOOOOOOOOO
hlc.misc.render_unfocused_fps = 60
hl.window_rule({
  match = { initial_class = [[^(.*\.exe|steam_proton)$]], workspace = 4 },
  render_unfocused = true,
})

-- :ratge:
hl.window_rule({
  match = { initial_class = [[^org\.keepassxc\.KeePassXC$]] },
  no_screen_share = true,
})
hl.window_rule({
  match = { initial_class = [[^org\.telegram\.desktop$]] },
  no_screen_share = true,
})
hl.layer_rule({ match = { namespace = "^notifications$" }, no_screen_share = true })

-- Layer rules
hl.layer_rule({ match = { namespace = "^foot-popup$" }, dim_around = true })

