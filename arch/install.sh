#!/bin/sh -ex

cd $(dirname $0)
sudo pacman -Syy
sudo pacman -S --noconfirm - < pacman.txt
paru -S --noconfirm google-chrome

rustup default stable
rustup component add rust-analyzer
go install golang.org/x/tools/gopls@latest
pip install python-lsp-server

for URL in $(cat repo.txt)
do
  git clone $URL ~/Documents/$(basename $URL)
done

for URL in $(cat tool.txt)
do
  wget -P ~/Documents/tool $URL
done

pip install pwntools
pip install ROPGadget
gem install --user-install one_gadget
cargo install urlencode
cargo install weggli

exit 0
