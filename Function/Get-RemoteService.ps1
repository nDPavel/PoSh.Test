<#	
<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	03.03.2016 09:09
     Update  on:    09.03.2016 15.56
	 Created by:   	pavel.linchik
	 Organization: 	��������� :)
	 Filename:     	Get-RemoteService
	===========================================================================
	.DESCRIPTION
		������� ������� � ��������� ����� �� ��������� �����
        �������� �������� ���� ������� ������
        Get-RemoteService -CompName   # HostName or Ip 
                          -SeviceName # Service(SystemName RemoteRegistry)
                          -Status     # Stop or Start
                          -StartMode  # Disabled(����������) or Manual(������) or Auto(��������������) � ����� ������� �������� ��������� Automatic   
#>

# ��������� ������ �������� ���� ������� ������
# ���� ��� Disabled �� ������ ��������� �� ����������
# ������� ���������� �������� ��� �������

function Global:Get-RemoteService {
    param
    ([Parameter (Mandatory = $True)]
        [String]$CompName,   #��� ����������
     [Parameter (Mandatory = $False)]   
        [String]$SeviceName, #��������� ��� ������
     [Parameter (Mandatory = $False)]   
        [String]$Status,     #Stop-Start ������
     [Parameter (Mandatory = $False)]   
        [String]$StartMode   #��� ������� ������
    )
    
    
    If ($Status -like "Start") {
        Write-Host -Object "����� ������� ����� �������� ������"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezDo.StartMode
        Write-Host -Object "������ ������"
            $RezDo.StartService()
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
        Write-Host -Object "����� ������� ����� �������"
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezDo.StartMode
    }
    elseif ($Status -like "Stop") {
        Write-Host -Object "��������� ������"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
        Write-Host -Object "������ ����� ���������� ������"
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezDo.StartMode
        Write-Host -Object "��������� ������"
            $RezDo.StopService()
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
        Write-Host -Object "����� ������� ������ ����� ���������"
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezDo.StartMode
    }
    if ($StartMode -like "Disabled") {
        Write-Host -Object "����� ���� ������� ������"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezDo.StartMode
        Write-Host -Object "��� ������� ������ (���������)"
            $RezDo.ChangeStartMode("Disabled")
        Write-Host -Object "����� ���� ������� ������ ����� ���������"
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezFin.StartMode
    }
    if ($StartMode -like "Manual") {
        Write-Host -Object "����� ���� ������� ������ �� ���������"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezFin.StartMode
        Write-Host -Object "��� ������� ������ (������)"
            $RezDo.ChangeStartMode("Manual")
        Write-Host -Object "����� ���� ������� ������ ����� ���������"
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezFin.StartMode
    }
    if ($StartMode -like "Auto") {
        Write-Host -Object "����� ���� ������� ������ �� ���������"
            $RezDo = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezDo.Name + " | " + $RezDo.State + " | " + $RezDo.StartMode
        Write-Host -Object "��� ������� ������ (��������������)"
            $RezDo.ChangeStartMode("Automatic")
        Write-Host -Object "����� ���� ������� ������ ����� ���������"
            $RezFin = Get-WmiObject -Class Win32_Service -Filter "Name='$SeviceName'" -ComputerName $CompName
            $RezFin.Name + " | " + $RezFin.State + " | " + $RezFin.StartMode
    }
	
}










