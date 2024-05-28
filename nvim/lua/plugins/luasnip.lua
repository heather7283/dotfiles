require("luasnip").setup()

-- Load snippets from ~/.config/nvim/lua/luasnip_snippets/
require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/luasnip_snippets/"})

