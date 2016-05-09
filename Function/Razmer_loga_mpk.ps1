<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.120
	 Created on:   	27.04.2016 13:54
	 Created by:   	pavel.linchik
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		Скрипт показывает размер папки мипко
        если папка привышает критический размер то требуется очистка логов mipko
#>


#Test-Path -Path "c:\ProgramData\MPK_old"

#размер файла
#$file_size = Get-Item -Path 'c:\ProgramData\MPK_old\1\D0000'
#$file_size.Length / 1mb
#$ip = "10.255.96.248"
#Размер директории

#$vzh = Get-Content -Path "d:\Job\all_pc.txt" -Encoding UTF8| 
 #   Where-Object {$_ -ne""} 
  $Gor = "Ekaterinburg"
    $vzh = (Get-ADObject -Filter {(ObjectClass -like "Computer")} | 
                where {$_.DistinguishedName -like ("*OU=$Gor*")})
    
    
    
    $vzh.name | ForEach-Object {$i = 0}{
    "{1}" -f $:_, $var
    #$_
    
    $TestPing = Test-Connection -ComputerName $_ -Count '2' -Quiet
    
    
    #проверка соединения
    if ($TestPing -like "True") {
        
        #Write-Host "Есть пинг"
        $TestP = Test-Path -Path ("\\" + $_ + "\c$\\ProgramData\MPK\")
        if ($TestP -like "True") {
            #Write-Host "Папка MPK Есть"
            $dir_size = (Get-ChildItem -Path ("\\" + $_ + "\c$\ProgramData\MPK\") -Recurse -Force |
            Measure-Object -Property length -Sum)
           #$dir_size.sum / 1Gb
            $size = $dir_size.sum / 1Gb
           #("{0:N4}" -f $size)
            $size_mach = "0,4000"
           #$size_mach
            if (("{0:N4}" -f $size) -gt $size_mach) {
                $_ + ";" + $size +"; "+ "Размер папки больше 400 мб" +";"+"Есть Пинг"
                }
                else{
                $_ + ";" + $size+ ";"+ "Размер папки меньше 400 мб"
            } 
        } 
        Else {
            #Write-Host "Папки нет"
            $_ + ";" +"Папки нет"
        }
        
    }
    else {
        
        #Write-Host "Нет пинга"
        $_ + ";" +"Нет пинга"
    }
} | 
Where-Object {$_ -ne""} |
Out-File -FilePath ("d:\Job\"+$Gor+".csv")

<#




    $dir_size = (Get-ChildItem -Path ("\\"+$_+"\c$\ProgramData\MPK\") -Recurse -Force |
    Measure-Object -Property length -Sum)
    $dir_size.sum / 1Gb

    $size = $dir_size.sum / 1Gb
     "{0:N2}" -f $size
    $size_mach = "0,80"
    $size_mach
        if($size -lt $size_mach){
            $_ + ";" + $size +";"+ "Размер папки больше 800 мб"
        }
        else{
            
        $_ + ";" + $size+";"+"Размер папки меньше 800 мб"
        }

    }
    
    
    
#>
