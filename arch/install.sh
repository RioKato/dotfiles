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

wget -P ~/Documents/petools https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
wget -P ~/Documents/petools https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64
wget -P ~/Documents/petools https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
wget -P ~/Documents/petools https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
wget -P ~/Documents/petools https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
wget -P ~/Documents/petools https://eternallybored.org/misc/netcat/netcat-win32-1.11.zip
wget -P ~/Documents/petools https://raw.githubusercontent.com/stealthcopter/deepce/main/deepce.sh
wget -P ~/Documents/petools https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe
wget -P ~/Documents/petools https://github.com/antonioCoco/RoguePotato/releases/download/1.0/RoguePotato.zip
wget -P ~/Documents/petools https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip
wget -P ~/Documents/petools https://github.com/jpillora/chisel/releases/download/v1.8.1/chisel_1.8.1_linux_amd64.gz

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
npm install --prefix ~/bin/js-beautify.npm js-beautify
cargo install urlencode
cargo install weggli

exit 0
