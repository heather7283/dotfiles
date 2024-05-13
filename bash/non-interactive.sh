# remove $HOME/bin from PATH, we'll put it there ourselves later
# (we need it to be the first entry)
if [[ "$PATH" == *"$HOME/bin:"* ]]; then
  PATH="${PATH/$HOME\/bin/}"
fi
# remove . from PATH (not the greatest idea to have it there)
if [[ "$PATH" == *".:"* ]]; then
  PATH="${PATH/.:/}"
fi
PATH="${PATH#:}"

export PATH="$HOME/bin:$PATH"

