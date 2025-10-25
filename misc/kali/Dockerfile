FROM kalilinux/kali-rolling:latest
WORKDIR /work
ENV TERM xterm-256color

RUN <<EOF
  set -e

  apt update
  apt install -y \
    zsh tmux \
    vim \
    xsel \
    fzf locate \
    rlwrap \
    jq \
    imagemagick exiftool \
    gcc clangd \
    gdb debuginfod binutils \
    golang \
    cargo \
    python3-pip python-is-python3 \
    ruby \
    default-jdk \
    npm \
    iproute2 \
    iputils-ping \
    nmap \
    proxychains4 \
    ncat \
    tcpdump \
    hydra \
    smbclient smbmap \
    ldapscripts \
    dnsutils dnsenum \
    ftp \
    snmp snmp-mibs-downloader snmpenum \
    smtp-user-enum \
    impacket-scripts evil-winrm crackmapexec \
    responder \
    metasploit-framework \
    exploitdb \
    gobuster ffuf dirsearch feroxbuster \
    sqlmap \
    wpscan \
    cewl \
    john hashcat hash-identifier \
    bloodhound bloodhound.py libgtk-3-0 \
    burpsuite mitmproxy \
    kpcli \
    ssh \
    default-mysql-client \
    mingw-w64
  apt clean
EOF

RUN <<EOF
  set -e

  curl -L https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz | tar zx -C /usr/local/bin
  ln -s /usr/local/bin/nvim-linux64/bin/nvim /usr/local/bin/nvim
EOF

RUN <<EOF
  set -e

  mkdir ~/Documents
  cd ~/Documents

  git clone --depth=1 https://github.com/InfosecMatter/Minimalistic-offensive-security-tools.git
  git clone --depth=1 https://github.com/drtychai/wordlists.git
  git clone --depth=1 https://github.com/danielmiessler/SecLists.git
  git clone --depth=1 https://github.com/dirkjanm/krbrelayx.git
  git clone --depth=1 https://github.com/drgreenthumb93/windows-kernel-exploits.git
  git clone --depth=1 https://github.com/Flangvik/SharpCollection.git
  git clone --depth=1 https://github.com/FuzzySecurity/PowerShell-Suite.git
  git clone --depth=1 https://github.com/Kevin-Robertson/Powermad.git
  git clone --depth=1 https://github.com/micahvandeusen/gMSADumper.git
  git clone --depth=1 https://github.com/pentestmonkey/php-reverse-shell.git
  git clone --depth=1 https://github.com/PowerShellMafia/PowerSploit.git
  git clone --depth=1 https://github.com/samratashok/nishang.git
  git clone --depth=1 https://github.com/swisskyrepo/PayloadsAllTheThings.git
  git clone --depth=1 https://github.com/synacktiv/php_filter_chain_generator.git
  git clone --depth=1 https://github.com/tennc/webshell.git
  git clone --depth=1 https://github.com/ticarpi/jwt_tool.git
  git clone --depth=1 https://github.com/urbanadventurer/username-anarchy.git
  git clone --depth=1 https://github.com/besimorhino/powercat.git

  wget -P tool https://github.com/opsec-infosec/nmap-static-binaries/releases/download/v2/nmap-x64.tar.gz
  wget -P tool https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
  wget -P tool https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas_linux_amd64
  wget -P tool https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
  wget -P tool https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
  wget -P tool https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
  wget -P tool https://eternallybored.org/misc/netcat/netcat-win32-1.11.zip
  wget -P tool https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe
  wget -P tool https://raw.githubusercontent.com/stealthcopter/deepce/main/deepce.sh
  wget -P tool https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe
  wget -P tool https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer64.exe
  wget -P tool https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET2.exe
  wget -P tool https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET35.exe
  wget -P tool https://github.com/BeichenDream/GodPotato/releases/download/V1.20/GodPotato-NET4.exe
  wget -P tool https://github.com/antonioCoco/RoguePotato/releases/download/1.0/RoguePotato.zip
  wget -P tool https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip
  wget -P tool https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz
  wget -P tool https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_windows_amd64.gz
  wget -P tool https://github.com/cyberark/kubeletctl/releases/download/v1.10/kubeletctl_linux_amd64
EOF

RUN <<EOF
  set -e

  go install github.com/ropnop/kerbrute@latest
  # pip install git-dumper
  # pip install certipy-ad
  npm -g install js-beautify
  cargo install ripgrep
  cargo install urlencode
  cargo install --features=ssl websocat
  go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
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

  chsh -s /bin/zsh
  touch ~/.hushlogin
  # /usr/share/neo4j/bin/neo4j-admin set-initial-password blood
EOF

CMD ["/bin/zsh"]
