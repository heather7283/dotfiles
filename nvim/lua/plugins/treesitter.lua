local utils = require('utils')

local options = {
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, buf)
      local disabled_langs = { "latex" }
      if utils.any(utils.map(function(x) return x == lang end, disabled_langs)) then
        return true
      end

      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end
  },
  indent = { enable = true },
  additional_vim_regex_highlighting = false,
}

vim.filetype.add({
  pattern = {
    [os.getenv("HOME").."/%.config/hypr/.*%.conf"] = "hyprlang"
  }
})

-- looks acceptable
vim.treesitter.language.register("bash", "execline")

return options

