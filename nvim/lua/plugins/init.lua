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
  {
    "mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        config = function()
          -- no-op intentionally
        end
      },
      {
        "williamboman/mason.nvim",
        cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
        config = function()
          -- no-op intentionally
        end
      },
    },
    config = function()
      require("plugins.lspconfig")
    end
  },

  -- completion
  {
    "hrsh7th/nvim-cmp",
    -- load in insert mode only
    event = "InsertEnter",
    config = function()
      require("plugins.cmp")
    end,
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        config = function()
          require("plugins.luasnip")
        end
      },
      {
        "windwp/nvim-autopairs",
        config = function()
          require("plugins.autopairs")
        end
      },
      -- cmp sources
      {
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
      },
    }
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    -- fuckers rewrote the entire thing on main branch and broke everything
    branch = "master",
    tag = "v0.10.0",
    pin = true,
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("plugins.treesitter")
    end
  },

  -- git integration
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    config = function()
      require("gitsigns").setup()
    end
  },

  {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    event = "VeryLazy",
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require("plugins.telescope")
    end
  },

  {
    'rhysd/clever-f.vim',
    event = "VeryLazy",
    config = function()
      require("plugins.clever-f")
    end
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    opts = {
      indent = {
        char = "▏",
        smart_indent_cap = true
      },
      scope = {
        char = "▎",
        show_start = false,
        show_end = false
      }
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    config = function()
      require("plugins.lualine")
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- theme
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 9999,
    config = function()
      require("plugins.everforest")
    end,
  }
}

require("lazy").setup(plugins)

