#!/bin/sh

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
git clone https://github.com/danielmiessler/SecLists.git ~/Documents/SecLists.git
git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git ~/Documents/PayloadsAllTheThings.git
git clone https://github.com/pentestmonkey/php-reverse-shell.git ~/Documents/php-reverse-shell.git
git clone https://github.com/samratashok/nishang.git ~/Documents/nishang.git
git clone https://github.com/PowerShellMafia/PowerSploit.git ~/Documents/PowerSploit.git
git clone https://github.com/FuzzySecurity/PowerShell-Suite.git ~/Documents/PowerShell-Suite.git
git clone https://github.com/drgreenthumb93/windows-kernel-exploits.git ~/Documents/windows-kernel-exploits.git
git clone https://github.com/andrew-d/static-binaries.git ~/Documents/static-binaries.git

rustup default stable
rustup component add rust-analyzer
go install golang.org/x/tools/gopls@latest
pip install python-lsp-server
git clone https://gitlab.com/exploit-database/exploitdb.git ~/bin/exploitdb.git
git clone https://github.com/maurosoria/dirsearch.git ~/bin/dirsearch.git
git clone https://github.com/synacktiv/php_filter_chain_generator.git ~/bin/php_filter_chain_generator.git
git clone https://github.com/ticarpi/jwt_tool.git ~/bin/jwt_tool.git
git clone https://github.com/urbanadventurer/username-anarchy.git ~/bin/username-anarchy.git
git clone https://github.com/GerbenJavado/LinkFinder.git ~/bin/LinkFinder.git
git clone https://github.com/micahvandeusen/gMSADumper.git ~/bin/gMSADumper.git
wget -P ~/bin https://raw.githubusercontent.com/openwall/john/bleeding-jumbo/run/ssh2john.py
go install github.com/OJ/gobuster/v3@latest
go install github.com/ffuf/ffuf@latest
go install github.com/ropnop/kerbrute@latest
gem install --user-install evil-winrm
gem install --user-install wpscan
pip install sqlmap
pip install hash-id
pip install git-dumper
pip install pwntools
gem install --user-install one_gadget
npm install --prefix ~/bin/js-beautify.npm js-beautify
cargo install urlencode
