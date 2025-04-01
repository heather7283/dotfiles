vim.g.mapleader = " "

local map = function(mode, key, mapping, comment, ...)
  -- I can pass optional opts table here as 5th arg
  local args = {...}
  local extra_opts = args[0]

  local opts = {
    noremap = true,
    silent = true,
    desc = comment
  }

  if extra_opts ~= nil then
    for k, v in pairs(extra_opts) do
      opts[k] = v
    end
  end

  vim.keymap.set(mode, key, mapping, opts)
end


-- navigate within insert mode
map("i", "<C-h>", "<Left>", "Move left")
map("i", "<C-j>", "<C-o>gj", "Move down") -- FIXME: this seems cursed, there should be a better way
map("i", "<C-k>", "<C-o>gk", "Move up")
map("i", "<C-l>", "<Right>", "Move right")

-- Allow moving the cursor through wrapped lines with j, k
map({ "n", "v" }, "j", "gj", "Move down", { expr = true, noremap = false })
map({ "n", "v" }, "k", "gk", "Move up", { expr = true, noremap = false })

local is_man_pager = vim.tbl_contains(vim.v.argv, 'Man!')
if is_man_pager then
  local man = require("man_history")

  vim.keymap.set('n', 'M', function()
    man.open_page_under_cursor()
  end)

  -- Backward navigation (Shift+H)
  vim.keymap.set('n', 'H', function()
    man.prev()
  end)

  -- Forward navigation (Shift+L)
  vim.keymap.set('n', 'L', function()
      man.next()
  end)

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "man",
    once = true,
    callback = function()
      local man_page = vim.fn.expand("%:t")
      if man_page ~= "" then
        man.push({name = man_page, index = 1})
      end
    end,
  })

  vim.keymap.set('n', 'B', function()
    man.print_history()
  end)
end

vim.keymap.set('n', '<leader>tw', function()
    local cursor_pos = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', cursor_pos)
end, { desc = 'Trim trailing whitespace' })

vim.keymap.set('n', '<leader>nd', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
vim.keymap.set('n', '<leader>Nd', vim.diagnostic.goto_next, { desc = 'Previous Diagnostic' })

vim.keymap.set('n', '<leader>nh', function() vim.cmd(':noh') end, { desc = ':noh' })

vim.keymap.set('c', '<C-j>', '<Down>')
vim.keymap.set('c', '<C-k>', '<Up>')
vim.keymap.set('c', '<C-h>', '<Left>')
vim.keymap.set('c', '<C-l>', '<Right>')

