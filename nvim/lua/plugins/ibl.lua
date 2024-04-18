require("ibl").setup {
  indent = {
    char = "│",
    smart_indent_cap = true
  },
  scope = {
    show_end = false
  }
}

local hooks = require "ibl.hooks"
hooks.register(
  hooks.type.WHITESPACE,
  hooks.builtin.hide_first_space_indent_level
)
hooks.register(
  hooks.type.WHITESPACE,
  hooks.builtin.hide_first_tab_indent_level
)
