<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	19.02.2016 10:07
	 Created by:   	pavel.linchik
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

#ignore most commented out data like below
#only way to easily input reg-binary is to use an array to set to convert to hex
[int[]]$data = 221,07,12,00,05,00,27,00,17,00,55,00,58,00,143,03
#[hex]$data2 = dd070c0005001200140011002d0015007b00
#bytes = [Text.Encoding]::Unicode.GetBytes($data)

cd HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture
#recursive search starts in the directory cd'ed to
gci . -rec -ea SilentlyContinue | % {
if((get-itemproperty -Path $_.PsPath) -match “Role:1”)
{ $_.PsPath}
 
#$_.PsPath | Out-File C:\scripts\test2.txt -width 120
#get rid of unneeded formatting in front
$_pathMin = $_.PsPath.Substring(54)
#get rid of unneeded formatting off end
$_pathMin = $_pathMin.Substring(0, $_pathMin.Length-11)
#put into correct path format
$intMicParent = "HKLM:" + $_pathMin
#$_pathMin + $bytes | Out-File C:\scripts\test3.txt -width 120
}
 
#this next part is needed to take
$acl = Get-Acl $intMicParent
 
# Admins may do everything:
$person = [System.Security.Principal.NTAccount]”Administrators”
$access = [System.Security.AccessControl.RegistryRights]"FullControl"
$inheritance = [System.Security.AccessControl.InheritanceFlags]"None"
$propagation = [System.Security.AccessControl.PropagationFlags]"None"
$type = [System.Security.AccessControl.AccessControlType]"Allow"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule(`
$person,$access,$inheritance,$propagation,$type)
$acl.ResetAccessRule($rule)
 
# Everyone may only read and create subkeys:
$person = [System.Security.Principal.NTAccount]"Everyone"
$access = [System.Security.AccessControl.RegistryRights]"ReadKey"
$inheritance = [System.Security.AccessControl.InheritanceFlags]"None"
$propagation = [System.Security.AccessControl.PropagationFlags]"None"
$type = [System.Security.AccessControl.AccessControlType]"Allow"
$rule = New-Object System.Security.AccessControl.RegistryAccessRule(`
$person,$access,$inheritance,$propagation,$type)
$acl.ResetAccessRule($rule)
 
icacls $intMicParent /setowner "Administrator" /t
 
Set-itemproperty -path $intMicParent -name "Role:2" -value ([byte[]]$data)