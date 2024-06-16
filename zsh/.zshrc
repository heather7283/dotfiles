# ========== General options ==========
# vi keybinds
bindkey -v
# match files beginning with a . without explicitly specifying the dot
setopt globdots
# Load completions
if [ ! -d ~/.cache/zsh/ ]; then mkdir -p ~/.cache/zsh/; fi
autoload -Uz compinit && compinit -d ~/.cache/zsh/zcompdump
zstyle ':completion:*' menu select
# Additional completions
fpath=("$HOME/.config/zsh/completions/" $fpath)
# ========== General options ==========


# ========== Prompt ==========
# Prompt
case "$HOST" in
  "FA506IH")
    export PS1="%B %1~ %0(?.:З.>:З)%b ";;
  "QboxBlue")
    export PS1="%F{blue}%B%n@%m%b%f %1~ %B%(#.#.$)%b ";;
  "archlinux") # default hostname for archlinux VMs
    export PS1="%B[VM] %n@%m%b %1~ %B%(#.#.$)%b ";;

esac

if [ -n "$TERMUX_VERSION" ]; then
  export PS1="%F{green}%B%n@%m%b%f %1~ %B%(#.#.$)%b "
fi
# ========== Prompt ==========


# ========== Plugins ==========
# Directory where plugins will be cloned
if [ -n "$XDG_DATA_HOME" ]; then
  _zsh_plugins_dir="$XDG_DATA_HOME/zsh/plugins/"
else
  _zsh_plugins_dir="$HOME/.local/share/zsh/plugins/"
fi

which fzf > /dev/null && if [ -f "$_zsh_plugins_dir/fzf-tab/fzf-tab.plugin.zsh" ]; then
  source "$_zsh_plugins_dir/fzf-tab/fzf-tab.plugin.zsh"
  zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
  zstyle ':fzf-tab:*' default-color ''
  if [ -f ~/.config/fzf/flags ]; then
    zstyle ":fzf-tab:*" fzf-flags $(tr '\n' ' ' <~/.config/fzf/flags)
  fi
fi
if [ -f "$_zsh_plugins_dir/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]; then
  source  "$_zsh_plugins_dir/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
  fast-theme ~/.config/zsh/fsh-theme-overlay.ini >/dev/null
  # Prevents visual artifacts when pasting
  zle_highlight+=('paste:none')
fi
if [ -f "$_zsh_plugins_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$_zsh_plugins_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [ -d "$_zsh_plugins_dir/zsh-completions/src" ]; then
  fpath=("$_zsh_plugins_dir/zsh-completions/src" $fpath) 
fi

zsh-plugins-install() {
  which git > /dev/null || { echo "Install git first" && return 1 }
  
  # create plugins dir if doesn't exist
  if [ ! -d "$_zsh_plugins_dir" ]; then
    mkdir -pv "$_zsh_plugins_dir"
  fi

  if [ ! -d "$_zsh_plugins_dir/fzf-tab/" ]; then
    git clone 'https://github.com/Aloxaf/fzf-tab' "$_zsh_plugins_dir/fzf-tab"
  fi
  if [ ! -d "$_zsh_plugins_dir/zsh-autosuggestions/" ]; then
    git clone 'https://github.com/zsh-users/zsh-autosuggestions' "$_zsh_plugins_dir/zsh-autosuggestions"
  fi
  if [ ! -d "$_zsh_plugins_dir/fast-syntax-highlighting/" ]; then
    git clone 'https://github.com/zdharma-continuum/fast-syntax-highlighting' "$_zsh_plugins_dir/fast-syntax-highlighting"
  fi
  if [ ! -d "$_zsh_plugins_dir/zsh-completions/" ]; then
    git clone 'https://github.com/zsh-users/zsh-completions.git' "$_zsh_plugins_dir/zsh-completions"
  fi
}

zsh-plugins-clean() {
  echo -n "Remove $_zsh_plugins_dir? [y/N] "
  read -q confirm
  if [ "$confirm" = "y" ]; then
    rm -rfv "$_zsh_plugins_dir"
  else
    echo "Abort"
  fi
  unset confirm
}

zsh-plugins-update() {
  _old_pwd="$PWD"
  for _plugin_dir in "$_zsh_plugins_dir/"*; do
    echo "Updating $_plugin_dir"
    cd "$_plugin_dir"
    git pull
  done
  cd "$_old_pwd"
  unset _old_pwd _plugin_dir
}
# ========== Plugins ==========


# ========== ZLE ==========
# change cursor shape depending on mode
set-cursor-shape() {
  case "$1" in
    block) echo -ne '\e[2 q';;
    beam) echo -ne '\e[6 q';;
  esac
}
zle-keymap-select() {
  case $KEYMAP in
  vicmd) set-cursor-shape block;;
  viins|main) set-cursor-shape beam;;
  esac
}
zle -N zle-keymap-select
zle-line-init() {
  zle -K viins
  set-cursor-shape beam
  _ln_help_displayed=0
}
zle -N zle-line-init
# set beam cursor for each new prompt
reset_cursor() {set-cursor-shape beam}
preexec_functions+=(reset_cursor)
# start shell with beam cursor
set-cursor-shape beam

# search history with fzf on C-r
fzf-history-search() {
  # do nothing if less than 2 lines in history
  if [ "$#history" -lt 2 ]; then return; fi

  item="$(fc -rl 0 -1 | ftb-tmux-popup --with-nth 2.. --scheme=history)"
  zle vi-fetch-history -n "$item"
}
zle -N fzf-history-search
bindkey -M viins '\C-r' fzf-history-search
bindkey -M vicmd '\C-r' fzf-history-search

# paste selected file path into command line
fzf-file-search() {
  LBUFFER="${LBUFFER}$(find . -maxdepth 6 2>/dev/null | fzf --height=~50% --layout=reverse)"
  zle reset-prompt
}
zle -N fzf-file-search
bindkey -M viins '\C-f' fzf-file-search
bindkey -M vicmd '\C-f' fzf-file-search

# remind about ln syntax :xdd:
_ln_help_displayed=0
zle-line-pre-redraw() {
  if [ "$BUFFER" = "ln" ] && [ "$_ln_help_displayed" = 0 ]; then
    echo
    echo "ln [OPTION]... [-T] TARGET LINK_NAME"
    echo "ln [OPTION]... TARGET"
    echo "ln [OPTION]... TARGET... DIRECTORY"
    echo "ln [OPTION]... -t DIRECTORY TARGET..."
    zle reset-prompt
    _ln_help_displayed=1
  fi
}
zle -N zle-line-pre-redraw

# move cursor in insert mode with Ctrl+hjkl
bindkey -M viins '\C-h' vi-backward-char
bindkey -M viins '\C-l' vi-forward-char
bindkey -M viins '\C-j' vi-down-line-or-history
bindkey -M viins '\C-k' vi-up-line-or-history

# fixes weird backspace behaviour
bindkey -M viins '^?' backward-delete-char
# ========== ZLE ==========


# ========== Aliases ==========
which eza >/dev/null &&
  alias ll='eza --color=auto --icons=auto --long --no-quotes --group-directories-first' ||
  alias ll='ls -lhF --color=auto'
which doas >/dev/null && alias sudo='doas'
alias grep='grep --color=auto'
alias neofetch='fastfetch'
alias hyprrun='hyprctl dispatch exec -- '
alias cal='cal --year --monday'
alias e='exec'

alias ULTRAKILL='kill -KILL'
alias ULTRAPKILL='pkill -KILL'
alias ULTRAKILLALL='killall -KILL'

alias apt='apt --no-install-recommends'
alias fzfdiff='git status -s | \
  fzf -m --preview "git diff --color=always -- {2..}" | \
  sed "s/^.\{3\}//"'
# ========== Aliases ==========


# ========== Envvars ==========
which nvim >/dev/null && export MANPAGER='nvim -c ":set signcolumn=no" -c "Man!"'
export LESS='--use-color --RAW-CONTROL-CHARS'
export BASH_ENV=~/.config/bash/non-interactive.sh

typeset -U path
path=(. ~/bin $path)
# ========== Envvars ==========


# ========== Functions ==========
# least touch-starved linux user
touch() {
  if [ "$1" = "woman" ]; then
    echo "Stop it, you pervert!"
    return 1
  else
    command touch "$@"
  fi
}

# python venv management
mkvenv() {
  if [ ! -d ./venv ]; then
    python -m venv venv || return 
    source venv/bin/activate || return
    if [ -f requirements.txt ]; then
      pip install -r requirements.txt
    fi
  else
    echo -n "./venv exists, recreate? [y/N] "
    if read -q; then rm -rf ./venv && mkvenv; fi
  fi
}
alias venv='source venv/bin/activate'
alias unvenv='deactivate'

# run ls after every cd
ls_after_cd() { ll }
chpwd_functions+=(ls_after_cd)

# Wrapper for lf that allows to cd into last selected directory
lf() {
  export lf_cd_file="/tmp/lfcd.$$"

  command lf "$@"

  __dir="$(cat "$lf_cd_file" 2>/dev/null)"
  if [ -n "$__dir" ]; then cd "$__dir"; fi

  unset __dir
  rm "$lf_cd_file" 2>/dev/null
  unset lf_cd_file
}

# Create a directory and cd into it
mkcd() {
	mkdir --verbose --parents "$1"
	cd "$1"
}

# Extract zip archive into a subdirectory
unzipd() {
	mkdir "${1%.*}"
	unzip -d "${1%.*}" "$1"
}

# Create a directory and all parents if they don't exist
mkdirs() {
  mkdir --verbose --parents "$1"
}

tor_activate() {
  export all_proxy="socks5://127.0.0.1:9050"
  export RPROMPT="[proxy]"
}

tor_deactivate() {
  unset all_proxy
  unset RPROMPT
}

cppath() {
  realpath "$1" | wl-copy
}
# ========== Functions ==========

