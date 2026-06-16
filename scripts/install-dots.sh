#!/bin/sh

ask() {
    printf "$1 [y/N] "
    read -r answer
    case "$answer" in
        (y|Y) return 0 ;;
        (*) return 1 ;;
    esac
}

echo "This will call systemd-tmpfiles, potentinally overwriting existing files!"
if ! ask "Data loss may occur. Continue?"; then
  echo "Abort"
  exit 1
fi

# termux doesn't have systemd-tmpfiles so do this manually
rm -rfv ~/bin
ln -sv .config/bin ~/bin

systemd-tmpfiles --user --create

echo "Done"
echo "Make sure to put this in /etc/zsh/zshenv or whatever:"
echo '    export ZDOTDIR="$HOME/.config/zsh/"'

