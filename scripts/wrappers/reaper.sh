# I don't trust proprietary software
exec bwrap \
    --unshare-all \
    --dev-bind / / \
    --ro-bind ~ ~ \
    --bind ~/.config/REAPER/ ~/.config/REAPER/ \
    --bind /tmp /tmp \
    --bind ~/projects/reaper/ ~/projects/reaper/ \
    "${real_exe}" -nosplash "$@"

