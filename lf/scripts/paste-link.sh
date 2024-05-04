#!/usr/bin/env bash

die() {
  echo -n "paste link" >&2
  if [ -n "$1" ]; then echo -n ": $1"; fi
  exit 1
}

# required to split filenames properly
export IFS=$'\t\n'

link_type="$1"
if [ ! "$link_type" = "hard" ] && [ ! "$link_type" = "symbolic" ]; then
  die "wrong link type: $link_type"
fi
if [ "$link_type" = "symbolic" ]; then
  relative="$2"
  if [ ! "$relative" = "absolute" ] && [ ! "$relative" = "relative" ]; then
    die "wrong link type: $relative"
  fi
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

# read list of selected files
declare -a files
while IFS= read -r line; do
  files+=("$line")
done < <(tail "$buffer_file" -n +2)
if [ ${#files[@]} -eq 0 ]; then die "no files in buffer"; fi

# where to create links
target_dir="$PWD"
if [ ! -d "$target_dir" ]; then die "$target_dir is not a directory"; fi

# stderr from mv and cp commands will be redirected here
stderr_file="/tmp/lf-delete-stderr.$$"

if [ "$link_type" = "hard" ]; then
  link_command() {
    ln -v -t "$target_dir" -- "${files[@]}" 2>"$stderr_file"
    return "$?"
  }
elif [ "$link_type" = "symbolic" ] && [ "$relative" = "absolute" ]; then
  link_command() {
    ln -v -s -t "$target_dir" -- "${files[@]}" 2>"$stderr_file"
    return "$?"
  }
elif [ "$link_type" = "symbolic" ] && [ "$relative" = "relative" ]; then
  link_command() {
    ln -v -s -r -t "$target_dir" -- "${files[@]}" 2>"$stderr_file"
    return "$?"
  }
else
  die "wrong options: $link_type $relative"
fi

link_wrapper() {
  link_command

  # display error message if ln exited with non-zero exit code
  exit_status="$?"
  if [ "$exit_status" = 0 ]; then
    rm "$stderr_file"
  else
    if [ -n "$TMUX" ]; then
      printf "\033[31m[%d]: check %s for details\033[0m" "$exit_status" "$stderr_file"
      ~/.config/lf/scripts/tmux-popup.sh -E -- nvim "$stderr_file"
      rm "$stderr_file"
    else
      printf "\033[31m[%d]: check %s for details\033[0m" "$exit_status" "$stderr_file"
    fi
  fi
}

link_wrapper

