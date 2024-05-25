#!/usr/bin/env bash

# assuming cell_width=9 and cell_height=21, 80 cells wide and 24 cells tall
hyprctl dispatch exec '[float;pin;stayfocused; size 720 504]' -- foot --override colors.background=3D484D -- "$@"

