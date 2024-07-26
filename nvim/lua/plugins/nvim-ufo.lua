local options = {
  open_fold_hl_timeout = 150,
  provider_selector = function()
    return "treesitter"
  end,
  preview = {
    win_config = {
      border = { "│", "", "", "│", "┘", "─", "└", "│" },
      winhighlight = 'Normal:Normal,FloatBorder:WinSeparator',
      winblend = 0
    },
    mappings = {
      scrollE = '<C-j>',
      scrollY = '<C-k>',
      scrollU = '<C-u>',
      scrollD = '<C-d>',
      jumpTop = '[',
      jumpBot = ']'
    }
  },
}

vim.o.foldcolumn = '0' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.keymap.set('n', 'zR', require("ufo").openAllFolds)
vim.keymap.set('n', 'zM', require("ufo").closeAllFolds)
vim.keymap.set('n', 'zr', require("ufo").openFoldsExceptKinds)
vim.keymap.set('n', 'zm', require("ufo").closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)

vim.keymap.set("n", "+", "zo")
vim.keymap.set("n", "-", "zc")

vim.keymap.set('n', 'K', function()
    local winid = require('ufo').peekFoldedLinesUnderCursor()
    if not winid then
        -- choose one of coc.nvim and nvim lsp
        vim.lsp.buf.hover()
    end
end)

return options

