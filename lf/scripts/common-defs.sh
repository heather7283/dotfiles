echo_warn() {
  # bold, yellow
  printf '\033[1;33m[%s]: %s\033[0m\n' "$_script_name" "$1" >&2
}

echo_err() {
  # bold, red 
  printf '\033[1;31m[%s]: %s\033[0m\n' "$_script_name" "$1" >&2
}

echo_info() {
  # no special effects
  printf '[%s] %s\n' "$_script_name" "$1" >&2
}

if [ -z "$TMUX" ]; then
  ask() {
    # ask for user input,
    # optionally pass default answer as 2nd arg
    _default_ans="$2"
    if [ "$_default_ans" = "Y" ] || [ "$_default_ans" = "y" ]; then
      _prompt="[Y/n]"
    else
      _prompt="[y/N]"
    fi

    # bold
    printf '\033[1m[%s] %s %s \033[0m ' "$_script_name" "$1" "$_prompt" >&2
    read -r -N1 _ans
    if [ -z "$_ans" ]; then # no user answer, using default
      _ans="$_default_ans"
    fi
    
    if [ "$_ans" = "y" ] || [ "$_ans" = "Y" ]; then
      return 0
    else
      return 1
    fi
  }

  ask_warn() {
    _default_ans="$2"
    if [ "$_default_ans" = "Y" ] || [ "$_default_ans" = "y" ]; then
      _prompt="[Y/n]"
    else
      _prompt="[y/N]"
    fi

    # bold, orange
    printf '\033[1;33m[%s] %s %s \033[0m ' "$_script_name" "$1" "$_prompt" >&2
    read -r -N1 _ans
    if [ -z "$_ans" ]; then # no user answer, using default
      _ans="$_default_ans"
    fi
    
    if [ "$_ans" = "y" ] || [ "$_ans" = "Y" ]; then
      return 0
    else
      return 1
    fi
  }

  read_line() {
    # $1 - prompt
    # $2 - initial string
    _prompt="[${_script_name}] ${1}"
    printf '%s' "$_prompt" >&2

    read -r _ans -i "$2"

    _exitcode=$?
    printf '%s' "$_ans"
    return $_exitcode
  }
else
  ask() {
    ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 2 -E -- bash -c '
      _script_name='"$(printf '%q' "$_script_name")"'

      _TMUX="$TMUX"
      unset TMUX
      source ~/.config/lf/scripts/common-defs.sh
      TMUX="$_TMUX"

      ask '"$(printf '%q' "$1")"' '"$(printf '%q' "$2")"'
    '
    return $?
  }

  ask_warn() {
    ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 2 -E -- bash -c '
      _script_name='"$(printf '%q' "$_script_name")"'

      _TMUX="$TMUX"
      unset TMUX
      source ~/.config/lf/scripts/common-defs.sh
      TMUX="$_TMUX"

      ask_warn '"$(printf '%q' "$1")"' '"$(printf '%q' "$2")"'
    '
    return $?
  }

  read_line() {
    ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 2 -E -- bash -c '
      _script_name='"$(printf '%q' "$_script_name")"'
      _prompt='"$(printf '%q' "[${_script_name}] ${1}")"'
      _initial_string='"$(printf '%q' "$2")"'
      
      _ans="$(zsh-readline -p "$_prompt" -s "$_initial_string")"
      _exitcode=$?
      printf "%s" "$_ans" >/tmp/lf-read-line
      exit $_exitcode
    '
    _exitcode=$?
    _ans="$(cat /tmp/lf-read-line 2>/dev/null)"
    rm -f /tmp/lf-read-line
    printf '%s' "$_ans"
    return $_exitcode
  }
fi

die() {
  echo_err "$1"
  exit 1
}

detect_busybox() {
  mv 2>&1 | grep -qe 'BusyBox'
  return $?
}

:reload() {
  # reloads lf UI
  lf -remote "send $id :reload"
}

# IFS: required to split filenames properly
export IFS=$'\t\n'

