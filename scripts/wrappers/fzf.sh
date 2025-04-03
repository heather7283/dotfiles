# default walker has unlimited depth
if [ -z "$FZF_DEFAULT_COMMAND" ]; then
    export FZF_DEFAULT_COMMAND="find -xdev -maxdepth 6"
fi

# host-specific config
if [ -f ~/.config/fzf/hosts/"${HOST}" ]; then
    export FZF_DEFAULT_OPTS="$(cat ~/.config/fzf/hosts/"${HOST}" ~/.config/fzf/default)"
else
    export FZF_DEFAULT_OPTS="$(cat ~/.config/fzf/default)"
fi

# beam cursor to make it more intuitive that we're in "insert mode"
printf '\033[6 q' >/dev/tty

