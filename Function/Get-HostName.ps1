
<#	.DESCRIPTION Get-HostName
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	18.01.2016 16:58
	 Created by:   	pavel.linchik
	 Organization: 	vivadengi
	 Filename:     	Get-HostName.ps1
	===========================================================================
	.DESCRIPTION
	Функция для получения Хост нейма по ip
	.StarParametrs
	Get-HostName -ip 'ип компьютера'
#>


function Get-HostName {
	Param($ip)
	[System.Net.Dns]::GetHostEntry($ip).HostName
}



