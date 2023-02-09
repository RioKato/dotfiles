#!/bin/sh

git clone --recursive https://github.com/BC-SECURITY/Empire.git ~/Downloads/Empire.git
wget -P ~/Documents/PETool https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
wget -P ~/Documents/PETool https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64
wget -P ~/Documents/PETool https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
wget -P ~/Documents/PETool https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
wget -P ~/Documents/PETool https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
wget -P ~/Documents/PETool https://eternallybored.org/misc/netcat/netcat-win32-1.11.zip
git clone https://github.com/danielmiessler/SecLists.git ~/Documents/SecLists.git
git clone https://github.com/samratashok/nishang.git ~/Documents/nishang.git
git clone https://gitlab.com/exploit-database/exploitdb.git ~/bin/exploitdb.git
git clone https://github.com/maurosoria/dirsearch.git ~/bin/dirsearch.git
git clone https://github.com/synacktiv/php_filter_chain_generator.git ~/bin/php_filter_chain_generator.git
git clone https://github.com/ticarpi/jwt_tool.git ~/bin/jwt_tool.git
go install github.com/OJ/gobuster/v3@latest
go install github.com/ffuf/ffuf@latest
go install github.com/ropnop/kerbrute@latest
gem install --user-install evil-winrm
gem install --user-install wpscan
pip install git-dumper
