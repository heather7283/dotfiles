local hlc = require('hlc')

require('binds')
require('rules')
require('autostart')

hl.monitor {
  output = "eDP-1",
  mode = "1920x1080",
  scale = 1,
  vrr = true,
}

hlc.input = {
  kb_layout = "us,ru", -- English and Russian layouts
  kb_options = "grp:alt_shift_toggle,caps:none", -- Switch with Alt+Shift

  numlock_by_default = true,
  follow_mouse = 1,

  repeat_rate = 60,
  repeat_delay = 250,

  touchpad = {
    natural_scroll = true,
  }
}

hlc.general = {
  gaps_in = 0,
  gaps_out = 0,

  border_size = 2,
  col = {
    inactive_border = "rgba(343F44FF)",
    active_border = "rgba(475258FF)",
  },

  resize_on_border = true,
  extend_border_grab_area = 5,

  layout = "dwindle",

  allow_tearing = false,

  snap = {
    enabled = true,
    border_overlap = false,
  },
}

hlc.group = {
  groupbar = {
    indicator_height = 3,
    rounding = 0,
    gaps_in = 0,
    gaps_out = 0,
    font_size = 16,
    text_offset = -16;
    render_titles = false,
    keep_upper_gap = false,

    col = {
      active = "rgba(475258FF)",
      inactive = "rgba(343F44FF)",
    },
  },

  col = {
    border_active = "rgba(475258FF)",
    border_inactive = "rgba(343F44FF)",
  },
}

hlc.decoration = {
  rounding = 0,
  blur = {
    enabled = false,
  },
  shadow = {
    enabled = false,
  },
}

hlc.animations = {
  enabled = false,
}

hlc.misc = {
  disable_splash_rendering = true,
  disable_hyprland_logo = true,

  disable_hyprland_guiutils_check = true,

  background_color = "rgba(1E2326FF)",

  mouse_move_enables_dpms = true,
  key_press_enables_dpms = true,

  -- Respect app focus requests
  focus_on_activate = true,
  -- I do not understand what is the purpose of primary selection
  middle_click_paste = false,

  initial_workspace_tracking = 1,

  vrr = 1,

  render_unfocused_fps = 60,

  on_focus_under_fullscreen = 1,
}

hlc.cursor = {
  zoom_rigid = true,
  zoom_detached_camera = false,
  zoom_disable_aa = true,

  --no_warps = true,
  hide_on_key_press = 0,

  -- hyprland is retarded. Even if my main gpu is is not nvidia, it will still
  -- disable things like hw cursor if it detects any nvidia on my system
  no_hardware_cursors = 0,
  use_cpu_buffer = 0,
}

hlc.binds = {
  disable_keybind_grabbing = true,
  allow_pin_fullscreen = true,
  scroll_event_delay = 0,
}

hlc.dwindle = {
  preserve_split = true,
}

hlc.render = {
  cm_enabled = false,
}

hlc.ecosystem = {
  no_update_news = true,
}

hlc.debug = {
  disable_logs = true,
  enable_stdout_logs = true,
}

