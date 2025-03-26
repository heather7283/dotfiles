## Environment variables
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
elif command -v vim >/dev/null 2>&1; then
    export EDITOR='vim'
else
    export EDITOR='vi'
fi

command -v less >/dev/null && export PAGER='less'
export LESS='--use-color --RAW-CONTROL-CHARS --chop-long-lines --mouse'

export MANOPT='-E\ ascii' # this forces man to only display ASCII (removes weird unicode quotes)
command -v nvim >/dev/null && export MANPAGER='nvim -c ":set signcolumn=no" -c "Man!"'

export BASH_ENV=~/.config/bash/non-interactive.sh

export CMAKE_EXPORT_COMPILE_COMMANDS=1

# I'll put it here I guess
typeset -U path
path=(~/bin $path)

