require("mason").setup()
require("mason-lspconfig").setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("*", {
  capabilities = capabilities
})

vim.lsp.config("lua_ls", {
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

vim.lsp.config("basedpyright", {
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic"
      }
    }
  },
  root_dir = function(filename, _) return vim.fn.matchstr(filename, ".*/") end
})

-- use system clangd
local clangd_path = vim.fn.exepath("clangd");
if clangd_path ~= "" then
  vim.lsp.config("clangd", {
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

