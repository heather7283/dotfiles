require("luasnip").setup()

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    if
      require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
      and not require("luasnip").session.jump_active
    then
      require("luasnip").unlink_current()
    end
  end,
})

-- Load snippets from ~/.config/nvim/lua/luasnip_snippets/
require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/luasnip_snippets/"})

