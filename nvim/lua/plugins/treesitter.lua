local options = {
  auto_install = true,
  highlight = {
    enable = true,
    disable = function(lang, buf)
      -- builtin nvim highlight for tmux somehow looks better than ts parser
      if lang == "tmux" then
        return true
      end

      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,
    additional_vim_regex_highlighting = { "markdown" },
  },
  indent = { enable = true },
}

vim.filetype.add({
  pattern = {
    ["${HOME}/%.config/hypr/.*%.conf"] = "hyprlang",
    [".*%.scd"] = "markdown",
    [".*%.frag"] = "glsl",
    [".*%.vert"] = "glsl",
  }
})

if vim.o.filetype ~= "man" then
    vim.cmd('filetype detect')
end

-- looks acceptable
vim.treesitter.language.register("bash", "execline")

require("nvim-treesitter.configs").setup(options)

