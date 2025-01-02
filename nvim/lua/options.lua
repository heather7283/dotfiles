-- shamelessly stolen from nvchad config
local opt = vim.opt
local o = vim.o
local g = vim.g

o.laststatus = 3
o.showmode = false

o.clipboard = "unnamedplus"
o.cursorline = true
o.cursorlineopt = "number"

-- Indenting
o.expandtab = true
o.shiftwidth = 4
o.smartindent = true
o.tabstop = 4
o.softtabstop = 4

opt.fillchars = { eob = " " }
o.ignorecase = true
o.smartcase = true
o.mouse = "a"

-- Numbers
o.number = true
o.numberwidth = 2
o.ruler = false

-- disable nvim intro
opt.shortmess:append "sI"

o.signcolumn = "yes"
o.splitbelow = true
o.splitright = true
o.timeoutlen = 400
o.undofile = true
o.autochdir = true

-- interval for writing swap file to disk, also used by gitsigns
o.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

-- g.mapleader = " "

-- disable some default providers
g["loaded_node_provider"] = 0
g["loaded_python3_provider"] = 0
g["loaded_perl_provider"] = 0
g["loaded_ruby_provider"] = 0

o.scrolloff = 8
o.smoothscroll = true

vim.diagnostic.config({
  signs = {
    text = {
      --[vim.diagnostic.severity.ERROR] = '󰅚',
      --[vim.diagnostic.severity.WARN] = '󰀪',
      --[vim.diagnostic.severity.INFO] = '󰋽',
      [vim.diagnostic.severity.ERROR] = '✗',
      [vim.diagnostic.severity.WARN] = '!',
      [vim.diagnostic.severity.INFO] = 'i',
      [vim.diagnostic.severity.HINT] = '󰌶',
    }
  },
  virtual_text = {
    virt_text_pos = "eol",
    prefix = '●',
  }
})

opt.termguicolors = true

-- prevents :h from splitting window, written by the box
vim.opt.splitbelow = false
vim.opt.splitright = false
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("help_in_current_window", { clear = true }),
  callback = function()
    if vim.bo.buftype == "help" then
      vim.cmd("only")
    end
  end,
})

