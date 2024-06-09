require("mason-lspconfig").setup({
  ensure_installed = {
    "basedpyright",
    "lua_ls",
    "bashls",
    "clangd",
    "tsserver",
    "texlab"
  }
})

local handlers = {
  -- default handler
  function(server_name)
    require("lspconfig")[server_name].setup({})
  end,

  ["basedpyright"] = function()
    -- man I heckin love lua
    require("lspconfig").basedpyright.setup({
      settings = {
        basedpyright = {
          analysis = { typeCheckingMode = "basic" }
        }
      }
    })
  end,

  ["lua_ls"] = function()
    require("lspconfig").lua_ls.setup({
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },

          runtime = {
            version = 'LuaJIT'
          },

          workspace = {
            checkThirdParty=false,
            library = {
              vim.fn.expand("$VIMRUNTIME/lua"),
              vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
              vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
            }
          }
        }
      }
    })
  end,
}

require("mason-lspconfig").setup_handlers(handlers)

