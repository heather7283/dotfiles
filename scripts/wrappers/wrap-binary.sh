#!/bin/sh

# THIS SCRIPT IS NOT SUPPOSED TO BE CALLED DIRECTLY!
# It will only work when it's called from PATH lookup

die() {
    printf '\033[1;31m%s wrapper: %s\033[m\n' "$0" "$1"
    exit 1
}

wrappers_dir=~/.config/scripts/wrappers

binary_name="${0##*/}"
binary_path="${0%/*}"

[ -n "${binary_path##/*}" ] && die "${binary_path} is not an absolute path"

old_path="$PATH"
PATH="$(echo "$PATH" | sed -e "s|${binary_path}||g;s|^:||;s|:\$||;s|::|:|g")"
real_exe="$(command -v "$binary_name")" || die "failed to find real ${binary_name} binary"
PATH="$old_path"

wrapper_script="${wrappers_dir}/${binary_name}.sh"
[ -r "$wrapper_script" ] && . "$wrapper_script" || die "${wrapper_script} does not exist"

exec "${real_exe}" "$@"

