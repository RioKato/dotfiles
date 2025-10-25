#!/bin/bash

cd $(dirname $0)
git submodule update --init --force --remote

IFS=$'\n'
for FILE in $(git ls-files)
do
  if [[ $FILE == .* ]] || [[ $FILE == bin/* ]]
  then
    SRC=`pwd`/$FILE
    DST=~/$FILE
    mkdir -p $(dirname "$DST")
    ln -snf "$SRC" "$DST"
  fi
done

if command -v gdb >& /dev/null
then
  wget -O ~/.gef.py -q https://gef.blah.cat/py
  ln -snf ~/dotfiles/.gdbinit ~/.gdbinit
fi
