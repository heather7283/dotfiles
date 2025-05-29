for arg in "$@"; do
    if [ -d "$arg" ]; then
        die "${arg} is a directory"
    fi
done

