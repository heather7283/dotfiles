## Environment variables
if command -v nvim >/dev/null; then
  export EDITOR='nvim'
else
  export EDITOR='vi'
fi
export PAGER='less'

# I'll put it here I guess
typeset -U path
path=(~/bin $path)

