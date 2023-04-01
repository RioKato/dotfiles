#!/bin/sh

for URL in $(cat repo.txt)
do
  git clone $URL ~/Documents/$(basename $URL)
done

for URL in $(cat tool.txt)
do
  wget -P ~/Documents/tool $URL
done
