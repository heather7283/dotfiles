if [ -f ~/.config/btop/hosts/"${HOST}"/btop.conf ]; then
    ln -sf ~/.config/btop/hosts/"${HOST}"/btop.conf ~/.config/btop/btop.conf
fi
if [ -f ~/.config/btop/hosts/"${HOST}"/theme.conf ]; then
    ln -sf ~/.config/btop/hosts/"${HOST}"/theme.conf ~/.config/btop/themes/mytheme.theme
fi
rm -f ~/.config/btop/btop.log

