#!/bin/sh

pacman -Syy
cd $(dirname $0)
pacman -S - < package.txt

systemctl start snapd
systemctl enable snapd
snap install impacket crackmapexec

paru snapd
paru nkf
paru dnsenum
paru smbmap
paru cewl

git clone https://github.com/lgandx/Responder.git /opt/Responder.git
git clone https://github.com/dirkjanm/krbrelayx.git /opt/krbrelayx.git
