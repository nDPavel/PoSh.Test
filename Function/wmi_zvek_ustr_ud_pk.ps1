#$c = (Get-WmiObject -Query "SELECT * FROM Win32_SoundDevice WHERE DeviceID='USB\\VID_093A&PID_2700&MI_02\\7&32B00A29&0&0002'")
#$c | select-object -Property * | Out-GridView 


$a = Get-WmiObject -Query "SELECT * FROM Win32_SoundDevice" -ComputerName  OO-KRSULIN-04.vivadengi.ru
$a | Select-Object -Property Caption    




