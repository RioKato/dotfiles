#!/bin/sh -ex

cd $(dirname $0)
sudo pacman -Syy
sudo pacman -S --noconfirm $(cat pacman.txt)
chsh -s /bin/zsh
gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"
exit 0
