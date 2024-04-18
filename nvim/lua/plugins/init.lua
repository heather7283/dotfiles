-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {
  -- lsp
  "williamboman/mason.nvim",
  { "williamboman/mason-lspconfig.nvim", dependencies = {"williamboman/mason.nvim"} },
  { "neovim/nvim-lspconfig", dependencies = {"mason-lspconfig.nvim"} },
  -- completion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-path",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "windwp/nvim-autopairs",
  -- treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- DAP
  "mfussenegger/nvim-dap",
  { "rcarriga/nvim-dap-ui", dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} },
  { "jay-babu/mason-nvim-dap.nvim", dependencies = {"williamboman/mason.nvim"} },
  "mfussenegger/nvim-dap-python",

  -- Indentation
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- File tree
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",

  -- statusline
  "nvim-lualine/lualine.nvim",
  -- theme
  { "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 9999,
    config = function()
      require("everforest").setup {
        background = "medium",
        -- ui_contrast = "high",
        colours_override = function(palette)
          palette.bg0 = "#232A2E"
        end,
      }
      require("everforest").load()
    end,
  }
}

require("lazy").setup(plugins)

require("plugins.mason")
require("plugins.lsp")
require("plugins.cmp")
require("plugins.dap")
require("plugins.treesitter")
require("plugins.lualine")
require("plugins.ibl")
require("plugins.nvimtree")
require("plugins.autopairs")
