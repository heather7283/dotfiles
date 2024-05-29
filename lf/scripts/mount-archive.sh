#!/usr/bin/env bash

die() {
  printf '\033[31mmount-archive: %s\033[0m' "$@" >&2
  exit 1
}

archive="$(realpath "$f")"
if [ -z "$archive" ]; then die "no filename provided"; fi
if [ -d "$archive" ]; then die "not mounting directory"; fi

archive_dirname="$(dirname "$archive")"

mountpoint="$(mktemp -d /tmp/lf-archive-mount.XXXXXX)"
if [ -z "$mountpoint" ]; then die "couldn't create mountpoint"; fi

mountpoint_dirname="$(dirname "$mountpoint")"

if [ ! -d ~/.cache/ratarmount/ ]; then
  mkdir -p ~/.cache/ratarmount/ || die "couldn't create cache dir";
fi

# NOTE: read-only mount
ratarmount \
  --parallelization "$(( $(nproc) / 2))" \
  --index-folders ~/.cache/ratarmount/ \
  -o 'ro' \
  "$archive" \
  "$mountpoint" || die "unable to mount archive"

lf -remote "send $id cd $mountpoint"

# check if after cd we are not under mountpoint anymore
# if so, unmount archive, remove mountpoint and clear on-cd and on-quit cmds
lf -remote "send $id cmd on-cd &\
  if [[ ! \"\$PWD\" =~ ^$mountpoint ]]; then \
    ratarmount -u $mountpoint; \
    lf -remote 'send $id cmd on-cd'; \
    lf -remote 'send $id cmd on-quit'; \
    rmdir $mountpoint; \
    if [ \"\$PWD\" = $(printf '%q' "$mountpoint_dirname") ]; then \
      lf -remote 'send $id cd $(printf '%q' "$archive_dirname")'; \
    fi; \
  fi"

# FIXME: doesn't work because lf client with $id doesn't exist already when this is run
#lf -remote "send $id cmd on-quit &\
#  lf -remote 'send $id select $(printf '%q' "$archive")' \
#  ratarmount -u $mountpoint; \
#  rmdir $mountpoint"

# TODO: make on-cd and on-quit cmds more flexible somehow,
# to allow multiple mounts at the same time
# Maybe implement hook system or something like this?

