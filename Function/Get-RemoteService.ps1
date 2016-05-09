<#	
<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	03.03.2016 09:09
     Update  on:    09.03.2016 15.56
	 Created by:   	pavel.linchik
	 Organization: 	вивабабло :)
	 Filename:     	Get-RemoteService
	===========================================================================
	.DESCRIPTION
		Функция запуска и остановки слежб на удаленном компе
        Добавлен параметр типа запуска службы
        Get-RemoteService -CompName   # HostName or Ip 
                          -SeviceName # Service(SystemName RemoteRegistry)
                          -Status     # Stop or Start
                          -StartMode  # Disabled(Отключение) or Manual(Ручной) or Auto(Автоматический) в самой системе ставится полностиь Automatic   
#>

# прописать логику проверки типа запуска службы
# Если тип Disabled то службу запустить не получиться
# сначало требуеться изменить тип запуска

function Global:Get-RemoteService {
    param
    ([Parameter (Mandatory = $True)]
        [String]$CompName,   #Имя компьютера
     [Parameter (Mandatory = $False)]   
        [String]$SeviceName, #Системное Имя службы
     [Parameter (Mandatory = $False)]   
        [String]$Status,     #Stop-Start службы
     [Parameter (Mandatory = $False)]   
        [String]$StartMode   #тип запуска службы
    )
    
    
    If ($Status -like "Start") {
        Write-Host -Object "Вывод статуса перед запуском службы"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezDo.StartMode
        Write-Host -Object "Запуск службы"
            $RezDo.StartService()
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
        Write-Host -Object "Вывод статуса после запуска"
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezDo.StartMode
    }
    elseif ($Status -like "Stop") {
        Write-Host -Object "Остановка службы"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
        Write-Host -Object "Статус перед остановкой службы"
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezDo.StartMode
        Write-Host -Object "Остановка службы"
            $RezDo.StopService()
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
        Write-Host -Object "Вывод статуса службы после остановки"
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezDo.StartMode
    }
    if ($StartMode -like "Disabled") {
        Write-Host -Object "Вывод типа запуска службы"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezDo.StartMode
        Write-Host -Object "Тип запуска службы (Отключена)"
            $RezDo.ChangeStartMode("Disabled")
        Write-Host -Object "Вывод Типа запуска службы после изменения"
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezFin.StartMode
    }
    if ($StartMode -like "Manual") {
        Write-Host -Object "Вывод типа запуска службы до изменения"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezFin.StartMode
        Write-Host -Object "Тип запуска службы (Ручной)"
            $RezDo.ChangeStartMode("Manual")
        Write-Host -Object "Вывод Типа запуска службы после изменения"
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezFin.StartMode
    }
    if ($StartMode -like "Auto") {
        Write-Host -Object "Вывод типа запуска службы до изменения"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezDo.StartMode
        Write-Host -Object "Тип запуска службы (Автоматический)"
            $RezDo.ChangeStartMode("Automatic")
        Write-Host -Object "Вывод Типа запуска службы после изменения"
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezFin.StartMode
    }
	
}










