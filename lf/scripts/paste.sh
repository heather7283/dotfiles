#!/usr/bin/env bash

die() {
  printf '\033[31mpaste: %s\033[0m' "$@" >&2
  exit 1
}

# required to split filenames properly
export IFS=$'\t\n'

# don't use --backup option with busybox coreutils
if mv 2>&1 | grep -qe 'BusyBox'; then
  printf '\033[31mWarn: --backup not supported, possible overwrite\033[0m'
  backup_arg=''
else
  backup_arg='--backup=numbered'
fi

# file where current file selection and mode is kept
if [ -n "$LF_DATA_HOME" ]; then
  buffer_file="$LF_DATA_HOME/lf/files"
else
  buffer_file=~/.local/share/lf/files
fi

if [ ! -f "$buffer_file" ]; then
  die "$buffer_file does not exist"
fi

# read mode and list of selected files
mode="$(head -n 1 "$buffer_file")"
declare -a files
while IFS= read -r line; do
  files+=("$line")
done < <(tail "$buffer_file" -n +2)
if [ ${#files[@]} -eq 0 ]; then die "no files in buffer"; fi

# Files will be moved/copied here
target_dir="$PWD"
if [ ! -d "$target_dir" ]; then die "$target_dir is not a directory"; fi

# stderr from mv and cp commands will be redirected here
stderr_file="/tmp/lf-paste-stderr.$$"

if [ "$mode" = "copy" ]; then
  paste_command() {
    cp $backup_arg -r -t "$target_dir" -- "${files[@]}" 2>"$stderr_file" &
    cmd_pid="$!"
    return "$cmd_pid"
  }
elif [ "$mode" = "move" ]; then
  paste_command() {
    mv $backup_arg -t "$target_dir" -- "${files[@]}" 2>"$stderr_file" &
    cmd_pid="$!"
    return "$cmd_pid"
  }
else
  die "wrong mode: $mode"
fi

paste_wrapper() {
  paste_command

  # monitor file moving/copying using `progress` utility
  if command -v progress >/dev/null; then
    { 
      while ps -p "$cmd_pid" >/dev/null; do
        progress --pid "$cmd_pid" --wait --wait-delay 0.25 | sed -n '2p'
      done
    } &
  fi
  
  # display error message if cp/mv exited with non-zero exit code
  wait "$cmd_pid"
  exit_status="$?"
  if [ "$exit_status" = 0 ]; then
    rm "$stderr_file"
  else
    if [ -n "$TMUX" ]; then
      printf "\033[31m[%d]: check %s for details\033[0m" "$exit_status" "$stderr_file"
      ~/.config/lf/scripts/tmux-popup.sh -E -- "$EDITOR" "$stderr_file"
      rm "$stderr_file"
    else
      printf "\033[31m[%d]: check %s for details\033[0m" "$exit_status" "$stderr_file"
    fi
  fi
}

paste_wrapper

