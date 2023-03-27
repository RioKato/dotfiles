#!/bin/sh

cp /etc/ssl/openssl.cnf /etc/ssl/openssl.cnf.bak

cat - <<EOF >> /etc/ssl/openssl.cnf

[provider_sect]
default = default_sect
legacy = legacy_sect

[default_sect]
activate = 1

[legacy_sect]
activate = 1
EOF
