local merge_tables = require("utils").merge_tables

local options = {
  background = "medium",
  transparent_background_level = 1,

  on_highlights = function(hl, palette)
    hl.DiagnosticUnnecessary = merge_tables({
      fg = palette.grey1,
      strikethrough = true,
      undercurl = false,
    }, hl.DiagnosticUnnecessary)
    hl.DiagnosticUnnecessary.link = nil

    -- do not override syntax highlighting, only change undercurl color
    hl.DiagnosticUnderlineHint = merge_tables({
      fg = palette.none,
    }, hl.DiagnosticUnderlineHint)
    hl.DiagnosticUnderlineInfo = merge_tables({
      fg = palette.none,
    }, hl.DiagnosticUnderlineInfo)
    hl.DiagnosticUnderlineWarn = merge_tables({
      fg = palette.none,
    }, hl.DiagnosticUnderlineWarn)
    hl.DiagnosticUnderlineError = merge_tables({
      fg = palette.none,
    }, hl.DiagnosticUnderlineError)
  end
}

return options
