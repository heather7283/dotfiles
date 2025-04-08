# ========== General options ==========
# vi keybinds
bindkey -v
KEYTIMEOUT=10

# match files beginning with a . without explicitly specifying the dot
setopt globdots
# allow comments in interactive shells
setopt INTERACTIVE_COMMENTS

# history size
HISTSIZE=2147483647
SAVEHIST=2147483647

# save each shell history into its own file (for funny statistics later)
zsh_history_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/history/"
[ ! -d "$zsh_history_dir" ] && mkdir -p "$zsh_history_dir"
HISTFILE="${zsh_history_dir}/histfile-${$}-${RANDOM}-${RANDOM}"

# don't load unnecessary eye candy
zsh_load_bloat=0

# lf config saves TERM value as OLDTERM because lf is reatrded
[ -n "$OLDTERM" ] && export TERM="$OLDTERM"
unset OLDTERM

# autoload functions path
fpath+=(~/.config/zsh/functions/)
# ========== General options ==========


# ========== Prompt ==========
# try to set color based on current distro if available
source <(grep -e '^ANSI_COLOR=' -e '^NAME=' /etc/os-release 2>/dev/null)
if [ "$NAME" = "Gentoo" ]; then
    # for some reason gentoo's ANSI_COLOR is green lmao wtf
    prompt_hostname_color_seq_start='%F{magenta}'
    prompt_hostname_color_seq_end='%f'
elif [[ "$NAME" =~ ^Debian.* ]]; then
    prompt_hostname_color_seq_start='%F{red}'
    prompt_hostname_color_seq_end='%f'
elif [ -n "$ANSI_COLOR" ]; then
    prompt_hostname_color_seq_start='%{'"$(printf "\033[${ANSI_COLOR}m")"'%}'
    prompt_hostname_color_seq_end='%{'"$(printf "\033[0m")"'%}'
elif [ "$NAME" = "Alpine Linux" ]; then
    prompt_hostname_color_seq_start='%F{blue}'
    prompt_hostname_color_seq_end='%f'
elif [ -n "$TERMUX_VERSION" ]; then
    prompt_hostname_color_seq_start='%F{green}'
    prompt_hostname_color_seq_end='%f'
else
    prompt_hostname_color_seq_start=''
    prompt_hostname_color_seq_end=''
fi
unset ANSI_COLOR
unset NAME

# ꙋ aka CYRILLIC SMALL LETTER MONOGRAPH UK (U+A64B) plays an important role here.
# It's rendered black so it effectively serves as a space, but since
# it's so obscure we are unlikely to ever encounter it in the wild.
# This makes it possible to jump between prompts by searching for this
# specific character. Yes, I am aware that OSC 133 exists, but for some reason
# zsh refuses to cooperate with me and I can't get OSC 133 to work no matter what.
local prompt_fake_space_seq='%F{black}ꙋ%f'

prompt_multiline=1

zstyle ':vcs_info:*' actionformats '%b | %a'
zstyle ':vcs_info:*' formats '%b'
zstyle ':vcs_info:*' enable git
autoload -Uz vcs_info
prompt_component_git() {
    vcs_info
    if [ -n "${vcs_info_msg_0_}" ]; then
        printf '󰊢 %s' "${vcs_info_msg_0_}"
    fi
}

prompt_component_distrobox() {
    if [ -n "$CONTAINER_ID" ]; then
        printf ' %s' "$CONTAINER_ID"
    fi
}

prompt_component_shlvl() {
    if [ "$SHLVL" -gt 1 ]; then
        printf ' shlvl %s' "${SHLVL}"
    fi
}

prompt_component_lf() {
    if [ "$lf_user_runninginlf" = 1 ]; then
        printf '󱏒 lf'
    fi
}

prompt_component_userhostname() {
    printf '%s' "%B%n@${prompt_hostname_color_seq_start}%m${prompt_hostname_color_seq_end}%b"
}

prompt_component_venv() {
    if [ -n "$VIRTUAL_ENV" ]; then
        local project_name="${${VIRTUAL_ENV%/*}##*/}"
        local max_len=16
        if [ "${#project_name}" -gt "$max_len" ]; then
            printf '󰌠 %s' "${project_name:0:$((max_len - 1))}…"
        else
            printf '󰌠 %s' "${project_name}"
        fi
    fi
}

prompt_component_exitcode() {
    if [ ! "$LAST_JOB_EXIT_STATUS" = 0 ]; then
        printf '%%B%%F{red}✗ %s%%f%%b' "$LAST_JOB_EXIT_STATUS"
    fi
}

prompt_component_ssh() {
    if [ -n "$SSH_CONNECTION" ]; then
        printf '󱂺 SSH'
    fi
}

typeset -a prompt_components
prompt_components=(userhostname exitcode git distrobox ssh venv lf)

update_prompt() {
    local new_prompt
    if [ "$prompt_multiline" = 1 ]; then
        new_prompt+="┌"

        local i
        for ((i = 1; i <= ${#prompt_components}; i++)); do
            local content="$(prompt_component_${prompt_components[i]})"

            [ -z "$content" ] && continue
            [ "$i" = 1 ] && content="[${content}]" || content="-[${content}]"

            new_prompt+="${content}"
        done

        new_prompt+=$'\n'"└[%24<…<%3~%<<]${prompt_fake_space_seq}%B%(#.#.$)%b "
    else
        # username@ (bold) hostname (colored)
        new_prompt+="%B%n@${prompt_hostname_color_seq_start}%m${prompt_hostname_color_seq_end}%b"
        # last component of pwd or ~ if in home
        new_prompt=+" %1~${prompt_fake_space_seq}"
        # # or $ depending on user (bold)
        new_prompt+="%B%(#.#.$)%b "
    fi

    PS1="$new_prompt"
}
update_prompt

case "$HOST" in
    (FA506IH) zsh_load_bloat=1;;
esac
# ========== Prompt ==========


# ========== Plugins ==========
# Directory where plugins will be cloned
zsh_plugins_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/plugins"

if [ -d "$zsh_plugins_dir/zsh-completions/src" ]; then
    fpath=("$zsh_plugins_dir/zsh-completions/src" $fpath)
fi

if [ -d "$zsh_plugins_dir/gentoo-zsh-completions/src" ]; then
    fpath=("$zsh_plugins_dir/gentoo-zsh-completions/src" $fpath)
fi

# Additional completions
fpath=(~/.config/zsh/completions/ $fpath)

# Load completions
if [ ! -d ~/.cache/zsh/ ]; then mkdir -p ~/.cache/zsh/; fi
compinit_dumpfile="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh/zcompdump_${CONTAINER_ID:-default}"
autoload -Uz compinit && compinit -d "$compinit_dumpfile"
zstyle ':completion:*' menu select

if command -v fzf >/dev/null && [ -f "$zsh_plugins_dir/fzf-tab/fzf-tab.plugin.zsh" ]; then
    source "${zsh_plugins_dir}/fzf-tab/fzf-tab.plugin.zsh"
    zstyle ':fzf-tab:*' default-color ''
    zstyle ':fzf-tab:*' use-fzf-default-opts yes
fi

if [ ! "$zsh_load_bloat" -eq 0 ]; then
    if [ -f "$zsh_plugins_dir/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]; then
        source "$zsh_plugins_dir/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
        fast-theme ~/.config/zsh/fsh-theme.ini >/dev/null
        # Prevents visual artifacts when pasting
        zle_highlight+=('paste:none')
    fi

    if [ -f "$zsh_plugins_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
        source "$zsh_plugins_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi
fi

zsh-plugins-install() {
    command -v git >/dev/null || { echo "Install git first" && return 1 }

    # create plugins dir if doesn't exist
    if [ ! -d "$zsh_plugins_dir" ]; then
        mkdir -pv "$zsh_plugins_dir" || return 1
    fi

    [ ! -d "${zsh_plugins_dir}/fzf-tab" ] && (
        cd "${zsh_plugins_dir}"
        git clone --depth 1 'https://github.com/Aloxaf/fzf-tab'
    )
    [ ! -d "${zsh_plugins_dir}/zsh-autosuggestions" ] && (
        cd "${zsh_plugins_dir}"
        git clone --depth 1 'https://github.com/zsh-users/zsh-autosuggestions'
    )
    [ ! -d "${zsh_plugins_dir}/fast-syntax-highlighting" ] && (
        cd "${zsh_plugins_dir}"
        git clone --depth 1 'https://github.com/zdharma-continuum/fast-syntax-highlighting'
        find fast-syntax-highlighting/→chroma -type f -delete
    )
    [ ! -d "${zsh_plugins_dir}/zsh-completions" ] && (
        cd "${zsh_plugins_dir}"
        git clone --depth 1 'https://github.com/zsh-users/zsh-completions'
    )
    [ ! -d "${zsh_plugins_dir}/gentoo-zsh-completions" ] && (
        cd "${zsh_plugins_dir}"
        git clone --depth 1 'https://github.com/gentoo/gentoo-zsh-completions'
    )
}

zsh-plugins-clean() {
    echo -n "Remove ${zsh_plugins_dir}? [y/N] "
    local confirm
    if read -q confirm; then
        rm -rfv "$zsh_plugins_dir"
    else
        echo "Abort"
    fi
}

zsh-plugins-update() {
    if [ -z "$(ls -A "$zsh_plugins_dir")" ]; then
        echo "no plugins in ${zsh_plugins_dir}"
        return
    fi

    local plugin_dir
    for plugin_dir in "${zsh_plugins_dir}/"*; do
        echo "Updating ${_plugin_dir}"
        git -C "$_plugin_dir" stash
        git -C "$_plugin_dir" pull
        git -C "$_plugin_dir" stash pop
    done
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
    case "$KEYMAP" in
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

# start shell with beam cursor
set-cursor-shape beam

# search history with fzf on C-r
fzf-history-search() {
    local item="$(fc -rl 0 -1 | fzf --with-nth 2.. --scheme=history)"
    [ -n "$item" ] && zle vi-fetch-history -n "$item"
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
if command -v eza 1>/dev/null 2>&1; then
    alias ll='eza \
        --color=always \
        --icons=always \
        --long \
        --no-quotes \
        --group-directories-first \
        --group --smart-group'
    alias tree='ll --tree'
else
    alias ll='ls -lhF --color=always'
    alias tree='ll -R'
fi
command -v doas >/dev/null && alias sudo='doas'
command -v bsdtar >/dev/null && alias tar='bsdtar'
alias grep='grep --color=auto'
alias neofetch='fastfetch'
alias hyprrun='hyprctl dispatch exec -- '
alias cal='cal --year --monday'
alias nyx='nyx --config ~/.config/nyxrc'
alias e='exec'
alias gdb='gdb -q'
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias ffplay='ffplay -hide_banner'
alias chafa='chafa --passthrough none'
alias torrent='transmission-cli'
alias wlp='wl-paste'
alias wlc='wl-copy'

alias ULTRAKILL='kill -KILL'
alias ULTRAPKILL='pkill -KILL'
alias ULTRAKILLALL='killall -KILL'

alias apt='apt --no-install-recommends'
alias fzfdiff='git status -s | \
  fzf -m --preview "git diff --color=always -- {2..}" | \
  sed "s/^.\{3\}//"'
alias fzfgrep='FZF_DEFAULT_COMMAND=true fzf \
  --bind '\''change:reload(rg --files-with-matches --smart-case -e {q} || true)'\'' \
  --preview '\''rg \
    --pretty \
    --context "$((FZF_PREVIEW_LINES / 4))" \
    --smart-case \
    -e {q} {} 2>/dev/null'\'' \
  --preview-window up \
  --disabled'
# ========== Aliases ==========


# ========== Functions ==========
# distrobox convenience wrapper
dbox() {
    local subcmd="$1"
    shift 1 || return 1
    case "$subcmd" in
        (e) distrobox-enter "$@" ;;
        (c) distrobox-create "$@" ;;
        (s) distrobox-stop "$@" ;;
        (r) distrobox-rm "$@" ;;
        (s) distrobox-stop "$@" ;;
        (*) echo "unknown subcommand"; return 1;;
    esac
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
        if read -q; then
            rm -rf ./venv && mkvenv;
        fi
    fi
}
alias venv='source venv/bin/activate'
alias unvenv='deactivate'

# run ls after every cd
ls_after_cd() {
    ll | awk "
        BEGIN { extra = 0 }
        NR < int(${LINES} / 2) - 1 { print }
        NR >= int(${LINES} / 2) - 1 { extra += 1 }
        END { if (extra > 0) { print extra \" more items...\" } }
    "
}
chpwd_functions+=(ls_after_cd)

# Wrapper for lf that allows to cd into last selected directory
lf() {
    export lf_cd_file="${TMPDIR:-/tmp}/lfcd.$$"

    local lf_path="$(which -p lf)"
    "$lf_path" "$@"

    if [ -r "$lf_cd_file" ]; then
        local dir="$(<"$lf_cd_file")"
        rm "$lf_cd_file"
        [ -n "$dir" ] && cd "$dir"
    fi

    unset lf_cd_file
}

# Create a directory and cd into it
mkcd() {
	mkdir -pv "$1" && cd "$1"
}

cppath() {
  realpath "$1" | wl-copy
}

spek() {
    ffmpeg -i "$1" -lavfi showspectrumpic=s=960x540 -f image2pipe -vcodec png - 2>/dev/null |
        chafa -f sixel
}

running_in_tmux() {
    [ -n "$TMUX_PANE" ]
}

tmux_pane_visible() {
    tmux list-windows -f '#{window_active}' -F '#{window_visible_layout}' | \
        grep -qEe "([0-9]+x[0-9]+),([0-9]+),([0-9]+),${TMUX_PANE#%}"
}

running_in_hyprland() {
    [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]
}

foot_active_window() {
    hyprctl activewindow | grep -qe 'initialClass: foot-tmux$'
}
# ========== Functions ==========


# ========== Hooks ==========
declare -aU precmd_functions
declare -aU preexec_functions

# set beam cursor for each new prompt
reset_cursor() {
    set-cursor-shape beam
}
preexec_functions+=(reset_cursor)

save_job_start_time() {
    JOB_START_SECONDS="$SECONDS"
}
preexec_functions+=(save_job_start_time)

save_job_exit_status() {
    LAST_JOB_EXIT_STATUS="$?"
}
precmd_functions=(save_job_exit_status $precmd_functions)

autoload -U notify_job_finish
precmd_functions+=(notify_job_finish update_prompt)
# ========== Hooks ==========

if [ -z "$WAYLAND_DISPLAY" ] && [[ "$TTY" = /dev/tty* ]]; then
    if pgrep Hyprland 2>&1 1>/dev/null; then
        # FUCK YOU VAXRY
        printf '\033[1m!!!!!!!!!! WARNING !!!!!!!!!!\033[0m\n'
        printf '\033[1mDONT SWITCH BACK TO HYPRLAND, THIS WILL FREEZE WHOLE SYSTEM\033[0m\n'
        printf '\033[1mEXECUTE \033[0mpkill Hyprland\033[1m AFTER YOU ARE DONE HERE\033[0m\n'
        printf '\033[1m!!!!!!!!!! WARNING !!!!!!!!!!\033[0m\n'
    else
        if read -q '?Launch Hyprland? [y/N] '; then
            exec start-hyprland
        fi
    fi
fi

