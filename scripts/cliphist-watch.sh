#!/usr/bin/env bash

cliphist store

string="$(wl-paste | grep -P '^<.*src="[^"]*".*>$')"
if [ -n "$string" ]; then
  url="$(echo "$string" | grep -oP 'src="\K[^"]*')"
  curl -L "$url" | wl-copy
fi

