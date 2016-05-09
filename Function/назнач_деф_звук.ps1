$p = "D:\Job\scripts\PowerShell\Projects\Prosluhka\Temp\Role1.txt"
$c = (Get-WmiObject -Query "SELECT Name,DeviceID,PNPDeviceID  FROM Win32_SoundDevice WHERE DeviceID='USB\\VID_093A&PID_2700&MI_02\\7&32B00A29&0&0002'")
$c.PNPDeviceID


#cd HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture\
Get-ChildItem . -Recurse -ea SilentlyContinue 

 where-object {
    if((get-itemproperty -Path $_.PsPath) -match “Role:2”)
{ $_| Out-File $p -width 120}
  $_.PsPath.Substring
 <#
    #$_.PsPath | Out-File C:\scripts\test2.txt -width 120
    #get rid of unneeded formatting in front
    $_pathMin = $_.PsPath.Substring(54)
    $_pathMin
    #get rid of unneeded formatting off end
    $_pathMin = $_pathMin.Substring(0, $_pathMin.Length-11)
    $_pathMin
    #put into correct path format
    $intMicParent = "HKLM:" + $_pathMin
    $intMicParent
    #$_pathMin + $bytes | Out-File C:\scripts\test3.txt -width 120
   #> 
}


