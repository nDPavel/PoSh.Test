$a = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . |
	Select-Object -ExpandProperty IPAddress

$a

New-Label -FontSize 24 -On_Loaded {
    Register-PowerShellCommand -scriptBlock {     
        $window.Content.Content = (ipconfig | out-string).Trim()
    }
} -asjob