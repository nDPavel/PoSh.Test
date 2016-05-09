<#	описание
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	29.01.2016 14:00
	 Created by:   	pavel.linchik
	 Organization: 	vivadengi
	 Filename:     	Get-LoggedOn.ps1
	===========================================================================
	.DESCRIPTION
		функция поиска текущей сессии на пк
		
#>
Function Get-LoggedOn ($Comp = $env:computername)            
{            
	Get-WMIObject -Class Win32_ComputerSystem -Computer $Comp | 
    	Select-Object Username

}         

