#!/bin/sh

cd $(dirname $0)
pacman -Syy
pacman -S - < pacman.txt

systemctl start snapd
systemctl enable snapd
snap install impacket crackmapexec metasploit-framework
