## Environment variables
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
elif command -v vim >/dev/null 2>&1; then
    export EDITOR='vim'
else
    export EDITOR='vi'
fi

command -v less >/dev/null && export PAGER='less'
export LESS='--use-color --RAW-CONTROL-CHARS --chop-long-lines --mouse'

export MANOPT='-E\ ascii' # this forces man to only display ASCII (removes weird unicode quotes)
command -v nvim >/dev/null && export MANPAGER='nvim -c ":set signcolumn=no" -c "Man!"'
# prefer sections 2 and 3 over 1 (I don't care about stat command, I care about stat syscall)
export MANSECT='2:3:1:1p:8:3p:4:5:6:7:9:0p:tcl:n:l:p:o:1x:2x:3x:4x:5x:6x:7x:8x'

export BASH_ENV=~/.config/bash/non-interactive.sh

# this looks stupid, do not remove. Without this /bin/sh doesn't pick up this variable
export HOST="$HOST"

# XDG user dirs
export XDG_CONFIG_HOME=~/.config/
export XDG_DATA_HOME=~/.local/share/
export XDG_STATE_HOME=~/.local/state/
export XDG_CACHE_HOME=~/.cache/

# cmake is retarded
export CMAKE_EXPORT_COMPILE_COMMANDS=1
# Nvidia cache directory (prevent creating ~/.nv)
export __GL_SHADER_DISK_CACHE_PATH=~/.cache/nv/
export CUDA_CACHE_PATH=~/.cache/nv/
# npm cache directory
export npm_config_cache=~/.cache/npm
# pnpm store
export PNPM_HOME=~/.cache/pnpm
# move .cargo out of ~
export CARGO_HOME=~/.cache/cargo
# move go out of ~
export GOPATH=~/.cache/go
# move .gnupg out of ~
export GNUPGHOME=~/.local/share/gnupg
# why am I even writing those comments
export PYTHON_HISTORY=~/.cache/python_history
export TEXMFVAR=~/.cache/texlive/texmf-var
export ANDROID_USER_HOME=~/.local/share/android
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot=/home/heather/.config/java
export WINEPREFIX=~/.local/share/wineprefix
export INPUTRC=~/.config/inputrc

# I'll put it here I guess
typeset -U path
path=(~/bin ~/opt/bin $path)

