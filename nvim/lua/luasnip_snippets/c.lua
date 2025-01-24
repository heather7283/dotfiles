return {
  s({ trig = "ifdefguard", dscr = "header ifdef include guard"},
    fmta(
      [[
        #ifndef <>_H
        #define <>_H

        <>

        #endif /* #ifndef <>_H */

      ]],
      {
        f(function(_, snip)
          -- get filename without extension and uppercase it
          local filename = vim.fn.expand("%:t:r"):upper()
          return filename
        end),
        f(function(_, snip)
          -- repeat the same transformation
          local filename = vim.fn.expand("%:t:r"):upper()
          return filename
        end),
        i(0),
        f(function(_, snip)
          -- repeat again for the comment
          local filename = vim.fn.expand("%:t:r"):upper()
          return filename
        end),
      }
    )
  )
}
