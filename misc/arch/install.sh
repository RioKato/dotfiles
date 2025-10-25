#!/bin/sh -ex

cd $(dirname $0)
sudo -E pacman -Syy
sudo -E pacman -S --noconfirm $(cat pacman.txt)
chsh -s /bin/zsh
gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"
exit 0
