# Read a line of user input and outputs it to STDOUT
# Behaves similar to zsh's read -Er

bindkey -v

export PROMPT="> "

# If ZSH_READLINE_INITIAL_STRING is set, its value is set to be initial string
if [ -n "$ZSH_READLINE_INITIAL_STRING" ]; then
  initial_string="$ZSH_READLINE_INITIAL_STRING"
  
  zle-line-init() {
    BUFFER="$initial_string"
    CURSOR="$#BUFFER"
  }
  zle -N zle-line-init
fi

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

