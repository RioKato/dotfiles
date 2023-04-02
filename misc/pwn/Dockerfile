FROM ubuntu:22.04

RUN apt update && apt install -y software-properties-common && add-apt-repository -y \
  ppa:neovim-ppa/stable

RUN apt update && apt install -y \
  locales locales-all \
  git curl wget file \
  tmux zsh vim neovim \
  gcc \
  python3 python3-pip python-is-python3 python3-pylsp \
  ruby \
  openjdk-19-jdk \
  gdb debuginfod binutils

ARG GEF_URL=https://github.com/hugsy/gef.git
RUN git clone $GEF_URL ~/Documents/gef.git
RUN pip install pwntools
RUN pip install ROPGadget
RUN gem install one_gadget
ARG GHIDRA_URL=https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.2.3_build/ghidra_10.2.3_PUBLIC_20230208.zip
RUN wget -P ~/Downloads $GHIDRA_URL && unzip -d ~ ~/Downloads/ghidra_*.zip && rm ~/Downloads/ghidra_*.zip

ARG DOTFILES_URL=https://github.com/RioKato/dotfiles.git
RUN git clone $DOTFILES_URL ~/dotfiles && \
  chmod +x ~/dotfiles/deploy.sh && ~/dotfiles/deploy.sh

ENV LC_ALL en_US.UTF-8
CMD ["/bin/zsh"]
