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

