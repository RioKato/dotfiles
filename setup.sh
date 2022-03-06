#!/bin/sh

mkdir -p ~/.config
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
mkdir -p ~/.vim
ln -s ~/dotfiles/.vim/template ~/.vim/template
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.gdbinit ~/.gdbinit
ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases

