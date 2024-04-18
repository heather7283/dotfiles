#!/usr/bin/env bash

selected_theme="$(fzf +m <~/.config/themes/themes.list)"

for dir in ~/.config/themes/apps/*; do
  ln -sfv "$selected_theme" "$dir/current"
done

