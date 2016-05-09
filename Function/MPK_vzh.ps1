<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.120
	 Created on:   	26.04.2016 13:40
	 Created by:   	pavel.linchik
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


#$vzh = Get-Content -Path "d:\Job\msk.txt" | 
 #   Where-Object {$_ -ne""} 
  
    $vzh = (Get-ADObject -Filter {(ObjectClass -like "Computer")} | 
                where {$_.DistinguishedName -like "*OU=Moscow*"})
    
    $vzh | ForEach-Object {$i = 0}{
    "{1}" -f $:_, $var
    #$_ 
    $mpk = Test-Path -Path ("\\"+ $_ +"\c$\ProgramData\MPK\MPK.exe")
    $mpk64 = Test-Path -Path ("\\"+ $_ +"\c$\ProgramData\MPK\MPKl64.exe")
    
    #$_ + ";" + $mpk + ";" + $mpk64 
   
    if(($mpk -like "True") -and ($mpk64 -like "True")){
    $_ + ";" + "Установлен"    
        }
    else{
    
    $_ + ";" + "не установлен"
        }
    
     }|
     Where-Object {$_ -ne""}
    
