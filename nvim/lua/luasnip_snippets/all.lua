return {
  -- Example: how to set snippet parameters
  s(
    { -- Table 1: snippet parameters
      trig="example",
      dscr="An example snippet that expands 'example' into 'Hello, world!'",
      regTrig=false, -- is trig regex?
      wordTrig=true, -- prevent expanding when trigger is part of a larger word
      priority=100, -- default is 1000
      snippetType="snippet" -- or "autosnippet"
    },
    { -- Table 2: snippet nodes
      t("Hello, world!"), -- A single text node
    }
    -- Table 3, the advanced snippet options, is left blank.
  ),
}

