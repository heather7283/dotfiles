if [ -z "$_script_name" ]; then _script_name="common-defs"; fi

echo_warn() {
  # bold, yellow
  printf '\033[1;33m[%s] %s\033[0m\n' "$_script_name" "$1" >&2
}

echo_err() {
  # bold, red
  printf '\033[1;31m[%s] %s\033[0m\n' "$_script_name" "$1" >&2
}

echo_info() {
  # no special effects
  printf '[%s] %s\n' "$_script_name" "$1" >&2
}

die() {
  echo_err "$1"
  exit 1
}

detect_busybox() {
  # $1 - program to check
  [ -z "$1" ] && die "detect_busybox: argument expected"
  "$1" 2>&1 | grep -qe '^BusyBox'
  return $?
}

# check if lf data dir exists
if [ -n "$LF_DATA_HOME" ]; then
  # FIXME: not POSIX
  _lf_data_dir="${LF_DATA_HOME//\/\//\/}/lf"
else
  _lf_data_dir=~/.local/share/lf
fi


if [ ! -d "$_lf_data_dir" ]; then
  mkdir -p "$_lf_data_dir" || die "unable to create data dir $_lf_data_dir"
fi
# check if lf client id available in environment
if [ -z "$id" ]; then
  die "unable to determine lf client id"
else
  _lf_client_id="$id"
fi
# create lf data dir for this specific client
_lf_client_data_dir="${_lf_data_dir}/${id}"
if [ ! -d "$_lf_client_data_dir" ]; then
  mkdir -p "$_lf_client_data_dir" || die "unable to create data dir $_lf_client_data_dir"
fi

mktmpfile() {
  _name="${1:-tmpfile}"
  mktemp -p "$_lf_client_data_dir" "${_script_name}-${_name}.XXXXXX"
}

mktmpdir() {
  _name="${1:-tmpdir}"
  mktemp -d -p "$_lf_client_data_dir" "${_script_name}-${_name}.XXXXXX"
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
    # this shit is so cursed
    # $1 - prompt
    # $2 - initial string
    #_prompt="[${_script_name}] (this line will be ignored) ${1}"
    _initial_string="$2"

    detect_busybox flock && die "you need flock from util-linux for this!"

    _tmpfile="$(mktmpfile "read_line")"
    if [ -z "$_tmpfile" ]; then die "unable to create temp file"; fi
    _lockfile="$(mktmpfile "read_line")"
    if [ -z "$_lockfile" ]; then die "unable to create lock file"; fi

    #echo "$_prompt" >"$_tmpfile"
    echo "$_initial_string" >>"$_tmpfile"

    if [ "$EDITOR" = nvim ]; then
      cmd="flock -o ${_lockfile} nvim -c 'nnoremap <ESC> :q!<CR>' -c 'nnoremap <CR> :wq<CR>' '${_tmpfile}'"
    else
      cmd="flock -o ${_lockfile} ${EDITOR:-vi} '${_tmpfile}'"
    fi
    # hopefully this won't explode
    lf -remote "send ${_lf_client_id} \$${cmd}"

    sleep 0.5
    _ans="$(flock -o "${_lockfile}" cat "${_tmpfile}")"
    _exitcode="$?"

    rm "${_tmpfile}"
    rm "${_lockfile}"

    printf '%s' "$_ans"
    return "$_exitcode"
  }
else
  ask() {
    # FIXME: from here and onwards, printf '%q' is not POSIX
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
    _tmpfile="$(mktmpfile "read_line")"
    if [ -z "$_tmpfile" ]; then die "unable to create temp file"; fi
    ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 70% -E -- bash -c '
      _script_name='"$(printf '%q' "$_script_name")"'
      _prompt='"$(printf '%q' "[${_script_name}] ${1}")"'
      _initial_string='"$(printf '%q' "$2")"'
      _tmp_read_line_file='"$(printf '%q' "$_tmpfile")"'

      echo "$_initial_string" >"$_tmp_read_line_file"
      if [ "$EDITOR" = nvim ]; then
        nvim -c "nnoremap <ESC> :q!<CR>" -c "nnoremap <CR> :wq<CR>" "$_tmp_read_line_file"
      else
        "${EDITOR:-vi}" "$_tmp_read_line_file"
      fi
      exit $_exitcode
    '
    _exitcode=$?
    _ans="$(cat "$_tmpfile" 2>/dev/null)"
    rm -f "$_tmpfile"
    printf '%s' "$_ans"
    return $_exitcode
  }
fi

stderr_wrapper() {
  if [ -z "$1" ]; then die "no command provided for stderr wrapper"; fi
  cmd="$1"
  if ! command -v "$cmd" >/dev/null; then
    die "$cmd not found"
  fi

  _stderr_file="$(mktmpfile "stderr_wrapper-${cmd##*/}")"
  if [ -z "$_stderr_file" ]; then die "unable to create temp file"; fi

  # Call wrapped command
  shift 1
  "$cmd" "$@" 2>"$_stderr_file"
  _exit_status="$?"

  if [ ! "$_exit_status" = 0 ]; then
    echo_err "${_exit_status}: check ${_stderr_file} for details"
    if [ -n "$TMUX" ]; then
      if [ "$EDITOR" = nvim ]; then
        ~/.config/lf/scripts/tmux-popup.sh -E -- nvim -c "nnoremap <ESC> :q!<CR>" "$_stderr_file"
      else
        ~/.config/lf/scripts/tmux-popup.sh -E -- "${EDITOR:-vi}" "$_stderr_file"
      fi
      rm "$_stderr_file"
    fi
  else
    rm "$_stderr_file"
  fi

  return $_exit_status
}

#progress_wrapper() {
#  if [ -z "$1" ]; then die "no command provided for progress wrapper"; fi
#  cmd="$1"
#  if command -v "$cmd" >/dev/null; then :; else
#    die "$cmd not found"
#  fi
#
#  # monitor file moving/copying using `progress` utility
#  if command -v progress >/dev/null; then
#    { 
#      while ps -p "$cmd_pid" >/dev/null; do
#        progress --pid "$cmd_pid" --wait --wait-delay 0.25 | sed -n '2p'
#      done
#    } &
#  fi
#}

:reload() {
  # reloads lf UI
  lf -remote "send $_lf_client_id :reload"
}

:clear() {
  # clean copy/paste buffer
  lf -remote "send $_lf_client_id :clear"
}

:unselect() {
  # clear selection
  lf -remote "send $_lf_client_id :unselect"
}

:select() {
  # put cursor on $1
  case "$1" in
  */.*)
    lf -remote "send $_lf_client_id :set hidden";;
  esac
  lf -remote "send $_lf_client_id :select '$1'"
}

# IFS: required to split filenames properly
export IFS='
'

[ -n "$OLDTERM" ] && export TERM="$OLDTERM"

