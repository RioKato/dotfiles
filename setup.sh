#!/bin/sh

mkdir -p ~/.config/nvim
ln -s ~/dotfiles/.config/nvim/init.vim ~/.config/nvim/init.vim
mkdir -p ~/.vim
ln -s ~/dotfiles/.vim/template ~/.vim/template
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.gdbinit ~/.gdbinit
