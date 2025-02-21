require("mason").setup()
require("mason-lspconfig").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local handlers = {
  -- default handler
  function(server_name)
    require("lspconfig")[server_name].setup({
      capabilities = capabilities
    })
  end,

  ["basedpyright"] = function()
    -- man I heckin love lua
    require("lspconfig").basedpyright.setup({
      settings = {
        basedpyright = {
          analysis = { typeCheckingMode = "basic" }
        }
      },
      capabilities = capabilities,
      root_dir = function(filename, bufnr) return vim.fn.matchstr(filename, ".*/") end
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
      },
      capabilities = capabilities
    })
  end,
}
require("mason-lspconfig").setup_handlers(handlers)

-- use system clangd
local clangd_path = vim.fn.exepath("clangd");
if clangd_path then
  require("lspconfig").clangd.setup({
    cmd = {
      clangd_path,
      "--background-index",
      "--all-scopes-completion",
      "--completion-style=detailed",
      "--header-insertion=never",
    },
    capabilities = capabilities
  })
end

vim.keymap.set('n', 'K', vim.lsp.buf.hover)

