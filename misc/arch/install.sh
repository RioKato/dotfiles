#!/bin/sh -ex

cd $(dirname $0)
sudo pacman -Syy
sudo pacman -S --noconfirm $(cat pacman.txt)
paru -S --noconfirm google-chrome
chsh -s /bin/zsh

rustup default stable
rustup component add rust-analyzer
go install golang.org/x/tools/gopls@latest

gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"

exit 0
