# remove $HOME/bin from PATH, we'll put it there ourselves later
# (we need it to be the first entry)
if [ -n "$HOME" ] && [[ "$PATH" == *"${HOME}/bin"* ]]; then
    PATH="${PATH/$HOME\/bin/}"
    PATH="${PATH//::/:}"
    PATH="${PATH#:}"
    PATH="${PATH%:}"
fi

export PATH="${HOME}/bin:${HOME}/opt/bin:${PATH}"

