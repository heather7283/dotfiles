#!/bin/sh

find "${XDG_CACHE_HOME:?}" \
    \( \( -type f -a -atime +30 \) -o \( -type d -a -empty \) \) -printf "%s\n" -delete \
| awk \
    '{ size+=$1 } END { print NR, "deletions,", size / 1024 / 1024, "MB total" }'

