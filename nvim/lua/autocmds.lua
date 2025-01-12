-- I have no idea what it does, I copied it from nvchad, and if I
-- delete it shit stops working. Just leave it here and forget about it
vim.api.nvim_create_autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("NvFilePost", { clear = true }),
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local buftype = vim.bo[args.buf].buftype

    if not vim.g.ui_entered and args.event == "UIEnter" then
      vim.g.ui_entered = true
    end

    if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
      vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
      vim.api.nvim_del_augroup_by_name "NvFilePost"

      vim.schedule(function()
        vim.api.nvim_exec_autocmds("FileType", {})

        if vim.g.editorconfig then
          require("editorconfig").config(args.buf)
        end
      end)
    end
  end,
})

vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#E67E80" })
vim.api.nvim_create_autocmd({"BufWinEnter", "InsertLeave"}, {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == "" then
      vim.fn.clearmatches()
      vim.fn.matchadd('TrailingWhitespace', [[\v\s+$|^\s+$]])
    end
  end
})

-- for .h files, sets the filetype to "cpp" if .cpp files are found, otherwise sets it to "c"
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.h",
  callback = function()
    local dir = vim.fn.expand("%:p:h")
    local has_cpp = vim.fn.glob(dir .. "/*.cpp") ~= ""

    if has_cpp then
      vim.bo.filetype = "cpp"
    else
      vim.bo.filetype = "c"
    end
  end
})

-- for .h files, automatically insert include guard in empty file
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.h"},
  callback = function()
    -- Check if file is empty
    local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if first_line == nil or first_line == "" then
      local filename = vim.fn.expand("%:t:r"):upper()
      local guard = string.format([[
#ifndef %s_H
#define %s_H



#endif /* #ifndef %s_H */]], filename, filename, filename)
      vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.split(guard, "\n"))
      vim.api.nvim_win_set_cursor(0, {4, 0})
    end
  end
})

