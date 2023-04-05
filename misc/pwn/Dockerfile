FROM ubuntu:22.04

RUN <<EOF
  set -e

  apt update
  apt install -y software-properties-common
  add-apt-repository -y ppa:neovim-ppa/stable

  apt update
  apt install -y \
    locales locales-all \
    git curl wget file \
    tmux zsh vim neovim \
    gcc clangd \
    cargo \
    python3 python3-pip python-is-python3 python3-pylsp \
    ruby \
    openjdk-19-jdk \
    gdb debuginfod binutils

  apt clean
EOF

RUN <<EOF
  set -e

  GEF_URL=https://github.com/hugsy/gef.git
  git clone $GEF_URL ~/Documents/gef.git

  pip install pwntools
  pip install ROPGadget
  gem install one_gadget
  cargo install weggli

  GHIDRA_URL=https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.2.3_build/ghidra_10.2.3_PUBLIC_20230208.zip
  wget -P ~/Downloads $GHIDRA_URL
  unzip -d ~ ~/Downloads/ghidra_*.zip
  rm ~/Downloads/ghidra_*.zip
EOF

RUN <<EOF
  set -e

  DOTFILES_URL=https://github.com/RioKato/dotfiles.git
  git clone $DOTFILES_URL ~/dotfiles
  chmod +x ~/dotfiles/deploy.sh
  ~/dotfiles/deploy.sh
EOF

ENV LC_ALL en_US.UTF-8
CMD ["/bin/zsh"]
