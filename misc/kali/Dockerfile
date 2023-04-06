FROM kalilinux/kali-rolling:latest
WORKDIR /work

RUN <<EOF
  set -e

  apt update
  apt install -y \
    zsh tmux \
    vim neovim \
    xsel \
    fzf ripgrep locate \
    jq \
    imagemagick exiftool \
    golang \
    cargo \
    python3-pip python3-pylsp \
    npm \
    iproute2 \
    iputils-ping \
    nmap \
    ncat \
    tcpdump \
    hydra \
    smbclient smbmap \
    ldapscripts \
    dnsutils dnsenum \
    snmp snmpenum \
    smtp-user-enum \
    impacket-scripts evil-winrm crackmapexec \
    responder \
    metasploit-framework \
    exploitdb \
    gobuster ffuf dirsearch \
    sqlmap \
    wpscan \
    cewl \
    john hashcat hash-identifier \
    bloodhound bloodhound.py libgtk-3-0
  apt clean
EOF

RUN <<EOF
  set -e

  mkdir ~/Documents
  cd ~/Documents

  git clone https://github.com/andrew-d/static-binaries.git
  git clone https://github.com/danielmiessler/SecLists.git
  git clone https://github.com/dirkjanm/krbrelayx.git
  git clone https://github.com/drgreenthumb93/windows-kernel-exploits.git
  git clone https://github.com/Flangvik/SharpCollection.git
  git clone https://github.com/FuzzySecurity/PowerShell-Suite.git
  git clone https://github.com/Kevin-Robertson/Powermad.git
  git clone https://github.com/micahvandeusen/gMSADumper.git
  git clone https://github.com/pentestmonkey/php-reverse-shell.git
  git clone https://github.com/PowerShellMafia/PowerSploit.git
  git clone https://github.com/samratashok/nishang.git
  git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git
  git clone https://github.com/synacktiv/php_filter_chain_generator.git
  git clone https://github.com/tennc/webshell.git
  git clone https://github.com/ticarpi/jwt_tool.git
  git clone https://github.com/urbanadventurer/username-anarchy.git

  wget -P tool https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
  wget -P tool https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64
  wget -P tool https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
  wget -P tool https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
  wget -P tool https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
  wget -P tool https://eternallybored.org/misc/netcat/netcat-win32-1.11.zip
  wget -P tool https://raw.githubusercontent.com/stealthcopter/deepce/main/deepce.sh
  wget -P tool https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe
  wget -P tool https://github.com/antonioCoco/RoguePotato/releases/download/1.0/RoguePotato.zip
  wget -P tool https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip
  wget -P tool https://github.com/jpillora/chisel/releases/download/v1.8.1/chisel_1.8.1_linux_amd64.gz
  wget -P tool https://github.com/cyberark/kubeletctl/releases/download/v1.10/kubeletctl_linux_amd64
EOF

RUN <<EOF
  set -e

  go install github.com/ropnop/kerbrute@latest
  pip install git-dumper
  npm -g install js-beautify
  cargo install urlencode
EOF

RUN <<EOF
  set -e

  DOTFILES_URL=https://github.com/RioKato/dotfiles.git
  git clone $DOTFILES_URL ~/dotfiles
  chmod +x ~/dotfiles/deploy.sh
  ~/dotfiles/deploy.sh
EOF

RUN <<EOF
  set -e

  /usr/share/neo4j/bin/neo4j-admin set-initial-password blood
  updatedb
EOF

CMD ["/bin/zsh"]
