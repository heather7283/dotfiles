return {
  s({ trig = "\\begin", dscr = "latex environment"},
    fmta(
      [[
        \begin{<>}
          <>
        \end{<>}
      ]],
      {
        i(1, "name"),
        i(0),
        rep(1),
      }
    )
  )
}

