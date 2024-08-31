local autocmd = vim.api.nvim_create_autocmd

-- user event that loads after UIEnter + only if file buf is there
autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("NvFilePost", { clear = true }),
  callback = function(args)
    local file = vim.api.nvim_buf_get_name(args.buf)
    local buftype = vim.api.nvim_buf_get_option(args.buf, "buftype")

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
      end, 0)
    end
  end,
})

-- source: https://vi.stackexchange.com/q/8563
vim.api.nvim_set_hl(0, "TrailingWhitespace", { bg = "#E67E80" })
vim.cmd([[
let g:toggleHighlightTrailingWhitespace = 1
function! ToggleHighlightTrailingWhitespace()
  let g:toggleHighlightTrailingWhitespace = 1 - g:toggleHighlightTrailingWhitespace
  call RefreshHighlightTrailingWhitespace()
endfunction

function! RefreshHighlightTrailingWhitespace()
  if g:toggleHighlightTrailingWhitespace == 1 " normal action, do the hi
    " highlight TrailingWhitespace ctermbg=red guibg=red
    match TrailingWhitespace /\s\+$/
    augroup HighLightTrailingWhitespace
      autocmd BufWinEnter * match TrailingWhitespace /\s\+$/
      autocmd InsertEnter * match TrailingWhitespace /\s\+\%#\@<!$/
      autocmd InsertLeave * match TrailingWhitespace /\s\+$/
      autocmd BufWinLeave * call clearmatches()
    augroup END
  else " clear whitespace highlighting
    call clearmatches()
    autocmd! HighLightTrailingWhitespace BufWinEnter
    autocmd! HighLightTrailingWhitespace InsertEnter
    autocmd! HighLightTrailingWhitespace InsertLeave
    autocmd! HighLightTrailingWhitespace BufWinLeave
  endif
endfunction

autocmd BufWinEnter * call RefreshHighlightTrailingWhitespace()
autocmd BufWinLeave * call RefreshHighlightTrailingWhitespace()
nnoremap <leader>w :call ToggleHighlightTrailingWhitespace()<cr>
]])

