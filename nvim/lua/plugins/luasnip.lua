local ls = require("luasnip")

local opts = {
  history = true,
  updateevents = "TextChanged,TextChangedI"
}
ls.setup(opts)

-- https://github.com/L3MON4D3/LuaSnip/issues/258#issuecomment-1011938524
local function leave_snippet()
  if
    ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
    and require('luasnip').session.current_nodes[vim.api.nvim_get_current_buf()]
    and not require('luasnip').session.jump_active
  then
    require('luasnip').unlink_current()
  end
end
-- stop snippets when you leave to normal mode
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*",
  callback = leave_snippet,
})


vim.keymap.set({"i", "s"}, "<Tab>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  elseif ls.locally_jumpable() then
    ls.jump(1)
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Tab>", true, true, true),
    "n", false)
  end
end, {silent = true, noremap = true})

vim.keymap.set({"i", "s"}, "<S-Tab>", function()
  if ls.choice_active() then
    ls.change_choice(-1)
  elseif ls.locally_jumpable() then
    ls.jump(-1)
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true),
    "n", false)
  end
end, {silent = true, noremap = true})

-- Load snippets from ~/.config/nvim/lua/luasnip_snippets/
require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/luasnip_snippets/"})

