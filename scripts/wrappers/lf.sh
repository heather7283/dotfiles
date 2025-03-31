# on termux /tmp is not accessible
if [ -n "$TMPDIR" ]; then
  export LF_DATA_HOME="${TMPDIR}"
else
  export LF_DATA_HOME=/tmp
fi

# lf does not work nicely with tmux-256color
if [ "$TERM" = "tmux-256color" ]; then
  export OLDTERM="$TERM"
  export TERM="tmux"
fi

# host-specific configs
if [ -f ~/.config/lf/hosts/"${HOST}" ]; then
    set -- -config ~/.config/lf/hosts/"${HOST}" "$@"
else
    set -- -config ~/.config/lf/lfrc "$@"
fi

