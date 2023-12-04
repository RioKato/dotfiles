FROM ubuntu:22.04
ENV TERM xterm-256color

RUN <<EOF
  TZ=America/Los_Angeles
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
EOF

RUN <<EOF
  set -e

  apt update
  apt install -y software-properties-common
  add-apt-repository -y ppa:neovim-ppa/unstable
  add-apt-repository -y ppa:deadsnakes/ppa

  apt update
  apt install -y \
    locales locales-all \
    zsh tmux \
    vim neovim \
    xsel \
    fzf ripgrep locate \
    git curl wget file \
    gcc clangd \
    gdb gdbserver debuginfod binutils \
    ltrace strace rr \
    golang \
    cargo \
    python3 python3.11 python3-pip python-is-python3 \
    ruby \
    openjdk-19-jdk \
    npm
  apt clean

  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
  update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2
  pip install pyright
  pip install --upgrade autopep8
  pip install pdbpp

  wget -P ~/bin https://github.com/iovisor/bpftrace/releases/download/v0.19.1/bpftrace
  chmod +x ~/bin/bpftrace
EOF

RUN <<EOF
  set -e

  pip install pwntools
  pip install ROPGadget
  gem install one_gadget
  cargo install weggli
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
  updatedb
EOF

ENV LC_ALL en_US.UTF-8
CMD ["/bin/zsh"]
