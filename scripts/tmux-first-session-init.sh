#!/usr/bin/env bash

tmux split-pane -h btop

tmux display-popup -- bash -c "echo hi heater uwu; echo session init test"

fastfetch
exec zsh -i

