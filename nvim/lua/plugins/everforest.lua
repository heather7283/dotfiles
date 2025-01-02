local options = {
  background = "medium",
  transparent_background_level = 1,

  on_highlights = function(hl, palette)
    hl.DiagnosticUnnecessary = vim.tbl_deep_extend('keep', {
      fg = palette.grey1,
      strikethrough = true,
      undercurl = false,
    }, hl.DiagnosticUnnecessary)
    hl.DiagnosticUnnecessary.link = nil

    -- do not override syntax highlighting, only change undercurl color
    hl.DiagnosticUnderlineHint = vim.tbl_deep_extend('keep', {
      fg = palette.none,
    }, hl.DiagnosticUnderlineHint)
    hl.DiagnosticUnderlineInfo = vim.tbl_deep_extend('keep', {
      fg = palette.none,
    }, hl.DiagnosticUnderlineInfo)
    hl.DiagnosticUnderlineWarn = vim.tbl_deep_extend('keep', {
      fg = palette.none,
    }, hl.DiagnosticUnderlineWarn)
    hl.DiagnosticUnderlineError = vim.tbl_deep_extend('keep', {
      fg = palette.none,
    }, hl.DiagnosticUnderlineError)
  end
}

return options
