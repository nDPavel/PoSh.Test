<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	26.02.2016 16:34
	 Created by:   	pavel.linchik
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
#Аудио дивайсы в реестре
#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio


#import-module -Function c:\Windows\System32\WindowsPowerShell\v1.0\Modules\Get-RemoteService\Get-RemoteService.psd1

#$a = Get-WmiObject -Class Win32_SoundDevice 
#$a | Select-Object -Property Name,DeviceID


#поиск аудио устройств
#$c = (Get-WmiObject -Query "SELECT Name,DeviceID,PNPDeviceID  FROM Win32_SoundDevice WHERE DeviceID='USB\\VID_093A&PID_2700&MI_02\\7&32B00A29&0&0002'")
Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio" -Force


