#!/bin/sh -ex

cd $(dirname $0)
sudo pacman -Syy
sudo pacman -S --noconfirm - < pacman.txt

paru -S --noconfirm snapd
paru -S --noconfirm google-chrome
paru -S --noconfirm nkf
paru -S --noconfirm avaloniailspy

sudo systemctl start snapd
sleep 10
sudo snap install crackmapexec metasploit-framework

for URL in $(cat repo.txt)
do
  git clone $URL ~/Documents/$(basename $URL)
done

for URL in $(cat tool.txt)
do
  wget -P ~/Documents/tool $URL
done

rustup default stable
rustup component add rust-analyzer
go install golang.org/x/tools/gopls@latest
pip install python-lsp-server
go install github.com/OJ/gobuster/v3@latest
go install github.com/ffuf/ffuf@latest
go install github.com/ropnop/kerbrute@latest
gem install --user-install evil-winrm
gem install --user-install wpscan
pip install sqlmap
pip install hash-id
pip install git-dumper
pip install impacket
pip install pwntools
pip install ROPGadget
gem install --user-install one_gadget
npm install --prefix ~/Documents/js-beautify.npm js-beautify
cargo install urlencode
cargo install weggli

exit 0
