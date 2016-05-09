Function IpTest
{
    param ($Ip)
    $IpTest = Test-Connection -ComputerName $ip -Count '2' -Quiet
    $IpTest
}
clear

$rez = Get-content -Path 'D:\job\spis_pk.txt' | Where-Object {$_ -ne""} 
$rez | ForEach-Object { $i = 0 }{
    "{1}" -f $:_, $var
	$_
	#$Mic = (Get-WmiObject -Query "select * from Win32_SoundDevice where name='Webcam C110'" -ComputerName $_).name
   	$UserLog = Get-LoggedOn -Comp $_
	$_ + " | "+  (IpTest -ip $_) + " | " + $UserLog | ft -AutoSize
    
}| Where-Object {$_ -ne""} 

