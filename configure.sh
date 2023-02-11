#!/bin/sh

mkdir -p ~/.config
ln -s ~/dotfiles/.config/nvim ~/.config/nvim

ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.gdbinit ~/.gdbinit
ln -s ~/dotfiles/.docker/ ~/.docker 
ln -s ~/dotfiles/.bash_aliases ~/.bash_aliases

mkdir -p ~/.idapro
ln -s ~/dotfiles/.idapro/cfg ~/.idapro/cfg
ln -s ~/dotfiles/.idapro/themes ~/.idapro/themes

mkdir -p ~/.local/share/applications
ln -s ~/dotfiles/.local/share/applications/ida64.desktop ~/.local/share/applications/ida64.desktop 
ln -s ~/dotfiles/.local/share/applications/ida.desktop ~/.local/share/applications/ida.desktop 

mkdir -p ~/bin