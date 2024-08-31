local options = {
  fast_wrap = {},
  disable_filetype = { "TelescopePrompt", "vim" },
  enable_check_bracket_line = false
}

require("nvim-autopairs").setup(options)

-- insert () after selection functions in completion menu
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on(
  "confirm_done",
  cmp_autopairs.on_confirm_done()
)

