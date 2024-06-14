#!/usr/bin/env bash

echo "Search the internet for..."
query="$(zsh-readline | tr ' ' '+')"

if [ -z "$query" ]; then exit; fi

engine='https://duckduckgo.com/?t=ffab&q='

if ! pgrep "firefox"; then hyprctl dispatch exec firefox; fi
firefox "${engine}${query}"

