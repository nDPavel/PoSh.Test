<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	24.03.2016 13:47
	 Created by:   	pavel.linchik
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


add-type -Path "D:\Job\scripts\PowerShell\Projects\Prosluhka\soft\NAudio\NAudio.dll"
Add-Type -Path "D:\Job\scripts\PowerShell\Projects\Prosluhka\soft\NAudio\NAudio.WindowsMediaFormat.dll"

$defaultDevice = $devices.GetDefaultAudioEndpoint([NAudio.CoreAudioApi.DataFlow]::Capture, [NAudio.CoreAudioApi.Role]::Console)
$defaultDevice.FriendlyName
$defaultDevice.DeviceFriendlyName
#$defaultDeviceId = $defaultDevice.ID -replace '{.+}\.{(.+)}$', '$1'
#$defaultDeviceId






