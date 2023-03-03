#!/bin/sh

mkdir -p ~/.config
ln -s ~/dotfiles/.config/nvim ~/.config/nvim

ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.gdbinit ~/.gdbinit
ln -s ~/dotfiles/.docker/ ~/.docker 
ln -s ~/dotfiles/.bash_addon ~/.bash_addon
echo 'source ~/.bash_addon' >> ~/.bashrc
ln -s ~/dotfiles/.xprofile ~/.xprofile
ln -s ~/dotfiles/.Xmodmap ~/.Xmodmap

mkdir -p ~/.idapro
ln -s ~/dotfiles/.idapro/cfg ~/.idapro/cfg
ln -s ~/dotfiles/.idapro/themes ~/.idapro/themes

mkdir -p ~/.local/share/applications
ln -s ~/dotfiles/.local/share/applications/ida64.desktop ~/.local/share/applications/ida64.desktop 
ln -s ~/dotfiles/.local/share/applications/ida.desktop ~/.local/share/applications/ida.desktop 

mkdir -p ~/bin
ln -s ~/dotfiles/bin/bloodhound ~/bin/bloodhound

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
	       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
