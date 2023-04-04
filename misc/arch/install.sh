#!/bin/sh -ex

cd $(dirname $0)
sudo pacman -Syy
sudo pacman -S --noconfirm - < pacman.txt
paru -S --noconfirm google-chrome
chsh -s /bin/zsh

rustup default stable
rustup component add rust-analyzer
go install golang.org/x/tools/gopls@latest
pip install python-lsp-server

exit 0
