#!/bin/sh

cd $(dirname $0)

RR_CONF=/etc/sysctl.d/10-rr.conf
[ ! -e $RR_CONF ] && sysctl -w kernel.perf_event_paranoid=1 >> $RR_CONF

cp zen_workaround.py /usr/local/bin
cp zen_workaround.service /etc/systemd/system
systemctl daemon-reload
systemctl enable zen_workaround

cp aslr /usr/local/bin
update-binfmts --enable jar
