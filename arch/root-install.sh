#!/bin/sh

cd $(dirname $0)

pacman -S - < package.txt

git clone https://github.com/lgandx/Responder.git /opt/Responder.git
git clone https://github.com/dirkjanm/krbrelayx.git /opt/krbrelayx.git
