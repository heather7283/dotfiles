#!/usr/bin/env bash

# Silience all output
exec 1>/dev/null 2>&1

# Download images that copy as funny html tag thingies
string="$(wl-paste | grep -P '^<.*src="[^"]*".*>$')"
if [ -n "$string" ]; then
  url="$(echo "$string" | grep -oP 'src="\K[^"]*')"
  curl -L "$url" | cliphist store
fi

