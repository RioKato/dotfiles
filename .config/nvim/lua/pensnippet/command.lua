command_snippet = [[
dir /s/b FILE
where COMMAND
whoami /all
tasklist /svc
systeminfo
powershell -EncodedCommand COMMAND
type PATH | powershell -NoProfile -
net user USERNAME PASSWORD /add
net localgroup Administrators USERNAME /add
net use \\IP\C$ PASSWORD /user:USERNAME
sc qc SERVICE
sc config SERVICE bin_path="PATH"
cmdkey /list
runas /user:DOMAIN\USERNAME /savecred PATH
reg save HKLM\SAM PATH
reg save HKLM\SYSTEM PATH
rundll32 C:\windows\System32\comsvcs.dll,:\Windows\System32\rundll32.exe C:\windows\System32\comsvcs.dll, MiniDump PID PATH full
]]
