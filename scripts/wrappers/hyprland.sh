uid="$(id -u)"
if [ -z "${uid}" ]; then
    die "unable to determine current user's id"
fi

export XDG_RUNTIME_DIR="${TMPDIR:-/tmp}/${uid}-runtime-dir"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/dbus.sock"

if [ ! -d "$XDG_RUNTIME_DIR" ]; then
    mkdir -pv "$XDG_RUNTIME_DIR" || die "failed to create ${XDG_RUNTIME_DIR}"
fi

# https://github.com/hyprwm/Hyprland/pull/7358
export HYPRLAND_NO_SD_VARS=true

#gpu=/dev/dri/by-name/amdgpu-card
#if [ ! -e "$gpu" ]; then
#  echo "${gpu} doesn't exist!" >&2
#  exit 1
#fi
#
#real_gpu="$(realpath "$gpu")"
#export AQ_DRM_DEVICES="$real_gpu"

# if already running in hyprland...
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    exec "${real_exe}" --config ~/.config/hypr/nested.conf "$@"
else
    exec "${real_exe}" "$@"
fi

