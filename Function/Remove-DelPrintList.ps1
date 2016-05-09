<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	01.03.2016 17:33
	 Created by:   	pavel.linchik
	 Organization: 	VivaBablo
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		очистка очереди печати на удаленном пк.
		Remove-DelPrintList -CN #указываем Ip или HostName
#>

Function Remove-DelPrintList{
	param($CN)

	$TC = Test-Connection -ComputerName $CN -Count "2" -Quiet
	$Ph = ('\\' + $CN + '\c$\Windows\System32\spool\PRINTERS\')
	$TP = Test-Path $Ph

    if ($TC -like "True")
        {
		Write-Host -Object "ПК в сети"
			 Get-RemoteService -CompName $CN -SeviceName "Spooler" -TypeStart "WMI" -Status "Stop"
				Write-Host -Object "Очистка папки Spooler"
				Remove-Item -Path ($ph + "*") -Force
			 Get-RemoteService -CompName $CN -SeviceName "Spooler" -TypeStart "WMI" -Status "Start"
		}
	elseif ($TC -like "False") {
			Write-Host -Object "ПК в сети Нет"
		}
}

