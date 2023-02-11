#!/bin/sh

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install deno --locked
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

wget -P ~/Documents/PETool https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
wget -P ~/Documents/PETool https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64
wget -P ~/Documents/PETool https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
wget -P ~/Documents/PETool https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
wget -P ~/Documents/PETool https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
wget -P ~/Documents/PETool https://eternallybored.org/misc/netcat/netcat-win32-1.11.zip
wget -P ~/Documents/PETool https://raw.githubusercontent.com/stealthcopter/deepce/main/deepce.sh
git clone https://github.com/danielmiessler/SecLists.git ~/Documents/SecLists.git
git clone https://github.com/samratashok/nishang.git ~/Documents/nishang.git
git clone https://gitlab.com/exploit-database/exploitdb.git ~/bin/exploitdb.git
git clone https://github.com/maurosoria/dirsearch.git ~/bin/dirsearch.git
git clone https://github.com/synacktiv/php_filter_chain_generator.git ~/bin/php_filter_chain_generator.git
git clone https://github.com/ticarpi/jwt_tool.git ~/bin/jwt_tool.git
git clone https://github.com/urbanadventurer/username-anarchy.git ~/bin/username-anarchy.git
git clone https://github.com/GerbenJavado/LinkFinder.git ~/bin/LinkFinder.git
go install github.com/OJ/gobuster/v3@latest
go install github.com/ffuf/ffuf@latest
go install github.com/ropnop/kerbrute@latest
gem install --user-install evil-winrm
gem install --user-install wpscan
pip install git-dumper
pip install pwntools
gem install --user-install one_gadget
npm install --prefix ~/bin/js-beautify.npm js-beautify

bash -c "$(curl -fsSL https://gef.blah.cat/sh)"
