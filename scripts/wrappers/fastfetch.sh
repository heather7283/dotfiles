if [ -f ~/.config/fastfetch/hosts/"${HOST}"/config.jsonc ]; then
    exec "$real_exe" -c ~/.config/fastfetch/hosts/"${HOST}"/config.jsonc "$@"
else
    exec "$real_exe" "$@"
fi

