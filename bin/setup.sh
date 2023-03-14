#!/bin/bash

cd $(dirname $0)

for EXEC in $(find . -maxdepth 2 -type f -executable)
do
  if [ $0 == $EXEC ]
  then
    continue
  fi

  SRC=$EXEC
  DST=$(basename $SRC)

  echo ln -snf $SRC $DST

  select yn in "Yes" "No"
  do
    case $yn in
      Yes ) ln -snf $SRC $DST
        break;;
      No )
        break;;
    esac
  done
done

rm $0
