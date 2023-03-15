#!/bin/bash

cd $(dirname $0)

for FILE in $(git ls-files)
do
  if [[ $FILE == .* ]] || [[ $FILE == bin/* ]]
  then
    SRC=`pwd`/$FILE
    DST=~/$FILE
    mkdir -p $(dirname $DST)
    ln -snf $SRC $DST
  fi
done


sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
	       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
