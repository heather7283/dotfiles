# Read a line of user input and outputs it to STDOUT
# Behaves similar to zsh's read -Er

bindkey -v

if [ -n "$ZSH_READLINE_PROMPT" ]; then
  export PROMPT="$ZSH_READLINE_PROMPT"
else
  export PROMPT="> "
fi

# Set ZSH_READLINE_INITIAL_STRING to be initial string
zle-line-init() {
  BUFFER="$ZSH_READLINE_INITIAL_STRING"
  CURSOR="$#BUFFER"
  # if ZSH_READLINE_INITIAL_MODE is set to 'normal', enter vicmd mode 
  if [ "$ZSH_READLINE_INITIAL_MODE" = "normal" ]; then
    zle vi-cmd-mode
  fi
}
zle -N zle-line-init

# After user hits enter, print buffer contents to stdout and exit
accept-line() {
  echo -nE "$BUFFER"
  exit 0
}
zle -N accept-line

# Ctrl+D will make it exit with exit code 1 without outputting anything 
abort() {
  exit 1
}
zle -N abort
bindkey -v "^D" abort
bindkey -a "^D" abort

