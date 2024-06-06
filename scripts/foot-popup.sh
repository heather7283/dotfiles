#!/usr/bin/env bash

hyprctl dispatch exec -- footclient --server-socket /tmp/foot-popup-server.sock --override colors.background=3D484D --app-id foot-popup -- "$@"

