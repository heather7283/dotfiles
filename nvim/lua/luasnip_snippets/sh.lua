return {
  s({trig = "shebang", dscr = "Bash shebang"},
    {
      t("#!/usr/bin/env bash")
    }
  ),

  s({ trig = "debug", dscr = "Debug output redirection to a file"},
    fmt(
      "set -x; exec 1>{} 2>&1",
      { i(1, "file") }
    )
  )
}

