# default walker has unlimited depth
if [ -z "$FZF_DEFAULT_COMMAND" ]; then
    export FZF_DEFAULT_COMMAND="find -xdev -maxdepth 6"
fi

# host-specific config
if [ -f ~/.config/fzf/hosts/"${HOST}" ]; then
    export FZF_DEFAULT_OPTS_FILE=~/.config/fzf/hosts/"${HOST}"
fi

# beam cursor to make it more intuitive that we're in "insert mode"
printf '\033[6 q' >/dev/tty

