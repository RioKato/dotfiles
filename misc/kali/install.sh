#!/bin/sh

apt update
apt install -y $(cat apt.txt)

for URL in $(cat repo.txt)
do
  git clone $URL ~/Documents/$(basename $URL)
done

for URL in $(cat tool.txt)
do
  wget -P ~/Documents/tool $URL
done

go install github.com/ropnop/kerbrute@latest
pip install git-dumper
npm -g install js-beautify
cargo install urlencode

/usr/share/neo4j/bin/neo4j-admin set-initial-password blood
