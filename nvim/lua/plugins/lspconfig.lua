require("mason").setup()
require("mason-lspconfig").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local config_and_enable = function(name, settings)
  vim.lsp.config(name, settings)
  vim.lsp.enable(name, true)
end

vim.lsp.config("*", {
  capabilities = capabilities
})

config_and_enable("lua_ls", {
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

config_and_enable("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic"
      }
    }
  },
  root_dir = function(filename, on_dir)
    on_dir(vim.fn.matchstr(filename, ".*/"))
  end
})

-- use system clangd
local clangd_path = vim.fn.exepath("clangd");
if clangd_path ~= "" then
  config_and_enable("clangd", {
    cmd = {
      clangd_path,
      "--background-index",
      "--all-scopes-completion",
      "--completion-style=detailed",
      "--header-insertion=never",
    }
  })
end

-- cooked af
vim.cmd(":LspStart")

vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename)

