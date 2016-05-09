#Broadcast messages, by Maxzor1908 *12/3/2013*

#$Comp = "it-13.vivadengi.ru"
$Comp = "10.255.111.230"
$msg = "msg * 'вас не слышно))'"
Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList $msg -ComputerName $Comp
Get-Service messenger 




