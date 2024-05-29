#!/usr/bin/env bash

die() {
  printf '\033[31mdelete: %s\033[0m' "$@" >&2
  exit 1
}

# IFS: required to split filenames properly
export IFS=$'\t\n'

# don't use --backup option with busybox coreutils
if mv 2>&1 | grep -qe 'BusyBox'; then
  printf '\033[31mWarn: --backup not supported, possible overwrite; continue? [Y/n] \033[0m'
  read -r -N 1 ans
  if [ ! "$ans" = "y" ] && [ ! "$ans" = "Y" ]; then die "abort"; fi
  backup_arg=''
else
  backup_arg='--backup=numbered'
fi

# Die if there are no selected files; yes, it can happen
if [ -z "$fx" ]; then die "no files selected"; fi

# Generate name for trash subdir (current datetime)
dir="$(date '+%Y-%m-%dT%H:%M:%S')"
if [ -z "$dir" ]; then die "failed to get current time"; fi
trash_dir=~/.trash/"$dir"

# Determine if trash will be used
# If file is not under HOME, don't use trash
# (maybe check if files are on the same fs instead?)
if echo "$fx" | grep -qvEe "^${HOME}.*$"; then
  printf "\033[31mWARN: not using trash!\033[0m "
  use_trash=0
else
  use_trash=1
fi

# stderr from rm and mv commands will be redirected to this file
stderr_file="/tmp/lf-delete-stderr.$$"

# Command that will be called to delete files depends on
# whether we using trash or not
if [ "$use_trash" = 1 ]; then
  delete_command() {
    mkdir -p "$trash_dir" || die "failed to create $dir"
    mv -v $backup_arg -t "$trash_dir" -- $fx 2>"$stderr_file"
  }
else
  delete_command() {
    rm -vrf $fx 2>"$stderr_file"
  }
fi

# Wrapper for delete command that shows error message if 
# command returned non-zero exit status
delete_wrapper() {
  delete_command
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

# Don't confirm deletion if only 1 file is selected
# But still confirm deletion if not using trash
file_count="$(echo "$fx" | wc -l)"
if [ "$file_count" = 1 ]; then
  if [ "$use_trash" = 1 ]; then
    delete_wrapper
  else
    printf "delete anyway? [y/N] "
    read -r answer
    if [[ "$answer" =~ ^(y|Y|yes|Yes|YES)$ ]]; then
      delete_wrapper
    else
      die "aborted by user"
    fi
  fi
  exit 
fi

# When not running in tmux
if [ -z "$TMUX" ]; then
  echo -n "delete $file_count files? [y/N] "
  read -r answer
  if [[ ! "$answer" =~ ^(y|Y|yes|Yes|YES)$ ]]; then
    die "abort";
  fi
  
  delete_wrapper
# When running in tmux
else
  # Behold: The most cursed piece of shell code I have written so far
  # We need to transfer some envvars from this script to the script 
  # that will be running in tmux popup
  # and the best way I came up with is to literally just engrave those
  # vars into the command string itself
  if ~/.config/lf/scripts/tmux-popup.sh -w 70% -h 2 -E -- bash -c '
    IFS='"$(printf '%q' "$IFS")"'
    file_count='"$(printf '%q' "$file_count")"'
    use_trash='"$(printf '%q' "$use_trash")"'
    trash_dir='"$(printf '%q' "$trash_dir")"'

    cd '"$(printf '%q' "$PWD")"'
    #cd '\'''"$PWD"\''''  # Ill leave this here for historical purposes and giggles
    
    if [ "$use_trash" = 0 ]; then
      printf "\033[31mFiles will NOT be trashed\033[0m\n";
    else
      echo "Files will be moved to $trash_dir"
    fi
    
    echo -n "delete $file_count files? [y/N] "
    read answer
    if [[ "$answer" =~ ^(y|Y|yes|Yes|YES)$ ]]; then
      exit 0
    fi

    exit 1
  '; then
    delete_wrapper
  fi
fi

