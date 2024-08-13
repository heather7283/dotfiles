#!/bin/sh

footclient --server-socket /tmp/foot-popup-server.sock --override colors.background=3D484D --app-id foot-popup -- "$@"

