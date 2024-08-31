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
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function(_, opts)
      require("plugins.lspconfig")
    end
  },
  {
    "neovim/nvim-lspconfig",
    event = "User FilePost",
    config = function(_, opts)
    end
  },
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
    config = function(_, opts)
      require("mason").setup()
    end
  },

  -- completion
  {
    "hrsh7th/nvim-cmp",
    -- load in insert mode only
    event = "InsertEnter",
    config = function(_, opts)
      require("cmp").setup(require("plugins.cmp"))
    end,
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        opts = {
          history = true,
          updateevents = "TextChanged,TextChangedI"
        },
        config = function(_, opts)
          require("luasnip").setup(opts)

          -- Load snippets from ~/.config/nvim/lua/luasnip_snippets/
          require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/luasnip_snippets/"})
        end
      },
      {
        "windwp/nvim-autopairs",
        config = function(_, opts)
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
        "micangl/cmp-vimtex",
      },
    }
  },

  {
    "kylechui/nvim-surround",
    -- event = "InsertEnter",
    config = function(_, opts)
      require("nvim-surround").setup(opts)
    end
  },

  {
    "kevinhwang91/nvim-ufo",
    lazy = false,
    dependencies = {
      "kevinhwang91/promise-async"
    },
    config = function(_, opts)
      require("ufo").setup(require("plugins.nvim-ufo"))
      -- vim.api.nvim_set_hl(0, "Folded", { bg = "#2D353B", force = true })
    end
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(require("plugins.treesitter"))
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = { "BufReadPost", "BufNewFile" }
  },

  -- DAP
  -- {
  --   "mfussenegger/nvim-dap",
  --   cmd = "DapContinue",
  --   dependencies = { "rcarriga/nvim-dap-ui", "mfussenegger/nvim-dap-python", "jay-babu/mason-nvim-dap.nvim", "nvim-neotest/nvim-nio" }
  -- },

  {
    "lervag/vimtex",
    ft = "tex",
    config = function()
      vim.g.maplocalleader = "\\"
      vim.g.vimtex_view_method = 'zathura'
    end
  },

  -- Indentation
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "User FilePost",
    config = function(_, opts)
      require("ibl").setup(require("plugins.ibl"))

      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
    end,
  },

  -- git integration
  {
    "lewis6991/gitsigns.nvim",
    event = "User FilePost",
    config = function(_, opts)
      require("gitsigns").setup(require("plugins.gitsigns"))
    end
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    config = function(_, opts)
      require("lualine").setup(require("plugins.lualine"))
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
      require("everforest").setup(require("plugins.everforest"))
      require("everforest").load()
    end,
  }
}

require("lazy").setup(plugins)

