require("mason-nvim-dap").setup {
  ensure_installed = {
    "python"
  },
}

--require("dap").setup()
require("dapui").setup {
  layouts = {
    {
      position = "bottom",
      size = 0.25,
      elements = {
        {
          id = "scopes",
          size = 0.5
        },
        {
          id = "console",
          size = 0.5
        },
      }
    }
  }
}
require("dap-python").setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")

