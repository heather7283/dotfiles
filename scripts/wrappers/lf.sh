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
    exec "${real_exe}" -config ~/.config/lf/hosts/"${HOST}" "$@"
else
    exec "${real_exe}" -config ~/.config/lf/lfrc "$@"
fi

