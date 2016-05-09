<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	21.04.2016 15:33
	 Created by:   	pavel.linchik
	 Organization: 	
	 Filename:     	Get-shedulTask
	===========================================================================
	.DESCRIPTION
		получаем информацию о шедуллерах установленных на удаленном и локальном пк
#>
#schtasks /query /tn "sendwma" /s OO-SALSK-02 /v /fo LIST

Function Get-ShedulTask{ 
    
    param(
        
    $NameJob,`           # /tn "sendwma"
    $ComputerName,`       #/s OO-SALSK-02
    $Details,`            #/v
    $FormaTab`           #/fo LIST or Table or csv
    
    )



}


