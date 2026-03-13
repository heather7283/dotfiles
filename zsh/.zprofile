# since .zshenv disables global rcs, source /etc/profile manually here
[ -r /etc/profile ] && . /etc/profile

## Environment variables
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
elif command -v vim >/dev/null 2>&1; then
    export EDITOR='vim'
else
    export EDITOR='vi'
fi

command -v less >/dev/null && {
    export PAGER='less'
    export LESS='--use-color --RAW-CONTROL-CHARS --chop-long-lines --mouse'
}

# this forces man to only display ASCII (removes weird unicode quotes) and dont break words
export MANOPT='-Eutf8 --nh --nj'
# prefer sections 2 and 3 over 1 (I don't care about stat command, I care about stat syscall)
export MANSECT='2:3:1:1p:8:3p:4:5:6:7:9:0p:n:l:p:o:1x:2x:3x:4x:5x:6x:7x:8x:tcl'
# use custom man pager script
export MANPAGER=~/.config/scripts/manpager.sh

# this looks stupid, do not remove. Without this /bin/sh doesn't pick up this variable
export HOST="$HOST"

if [[ ! -v PARSED_CONFIG_ENVIRONMENT_D ]]; then
    set -a
    . ~/.config/environment.d/*.conf
    set +a
fi

# I'll put it here I guess
typeset -U path
path=(~/bin ~/opt/bin $path)

