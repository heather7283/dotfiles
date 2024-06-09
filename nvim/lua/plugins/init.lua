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
        opts = {
          fast_wrap = {},
          disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
          require("nvim-autopairs").setup(opts)

          local cmp_autopairs = require "nvim-autopairs.completion.cmp"
          require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
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

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(require("plugins.treesitter"))
    end
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

  -- File tree
  {
    "nvim-tree/nvim-tree.lua",
    cmd = "NvimTreeOpen",
    config = function(_, opts)
      require("nvim-tree").setup(require("plugins.nvimtree"))
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" }
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

