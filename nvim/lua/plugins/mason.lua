require("mason").setup()

require("mason-lspconfig").setup {
    ensure_installed = { "pyright", "lua_ls", "bashls", "clangd", "tsserver" }
}

