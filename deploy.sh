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

if command -v gdb >& /dev/null
then
  wget -O ~/.gef.py -q https://gef.blah.cat/py
  wget -q -O- https://github.com/hugsy/gef/raw/main/scripts/gef-extras.sh | sh
  ln -snf ~/dotfiles/.gdbinit ~/.gdbinit
fi
