## some styles are set to the ugliest color combo on purpose
ugliest_color_combo='fg=#5D4E00,bg=#9B00C8'

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=red'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,underline'
ZSH_HIGHLIGHT_STYLES[suffix-alias]="$ugliest_color_combo"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=green,underline"
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green'
ZSH_HIGHLIGHT_STYLES[function]='fg=green'
ZSH_HIGHLIGHT_STYLES[command]='fg=green'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=red'
ZSH_HIGHLIGHT_STYLES[commandseparator]=''
ZSH_HIGHLIGHT_STYLES[hashed-command]="$ugliest_color_combo"
ZSH_HIGHLIGHT_STYLES[autodirectory]="$ugliest_color_combo"
ZSH_HIGHLIGHT_STYLES[path]='underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]=''
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=''
ZSH_HIGHLIGHT_STYLES[globbing]=''
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[command-substitution]="$ugliest_color_combo"
ZSH_HIGHLIGHT_STYLES[command-substitution-unquoted]=''
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]=''
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=blue'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=blue'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=blue'
ZSH_HIGHLIGHT_STYLES[process-substitution]=''
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=blue'
ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]='fg=blue'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=''
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=''
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=''
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=blue'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=blue'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=blue'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[assign]=''
ZSH_HIGHLIGHT_STYLES[redirection]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#828F86'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[default]=''

# background in visual mode (requires patched plugin)
zle_highlight+=('region:bg=#543A48')

