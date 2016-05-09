# ��������� �� ������������ �����-������. ������ ��������� �������� ���������� � ���������� ��������. �����? ����� �� �����.  
$prefer_server = "chel2.example.com"  
# ����������� � ������  
$domain = "LDAP://dc=example,dc=com"  
$root = New-Object DirectoryServices.DirectoryEntry $domain  
$adFind = New-Object Directoryservices.DirectorySearcher  
$adFind.SearchRoot = $root  
# ������� ��� ������������ �� ���������  
$username = $env:username  
  
# ������ �� ������, ���� ������ ����������� �� win2k3 � � ������������ � DN ���� Full Users (�� ���� ���� ������ ����������� � ��������-�������)  
# �.�. � ��� � ������ ���� ������������� � ������������, �� ������������� �� ���� ���������� �������� � ������������ ������  
# �.�. ��� � ��� � ������ OU, �������� ��������� �� DN.  
$adFind.Filter = "(&(objectClass=user)(!(ObjectClass=computer))(sAMAccountName=$username))"  
$user = $adFind.FindOne()  
if ($user.Path.Contains("Full_Users")) {  
    $osname = (gwmi -class Win32_OperatingSystem).Caption     
    if ($osname -match ".*2003.*") {              
            exit(0);  
    }  
}  
  
# ������������ ���� ��������� ���������  
$ad_printers = @{}  
$adFind.Filter = "(objectClass=printqueue)"  
$adFind.FindAll() | Sort-Object -Property Properties.servername | foreach-object {  
    if ($ad_printers.Contains($_.Properties.printername[0])) {  
        # �������� ���� �������� �� �������������� �������. ������� �� ����������������  
        if ($_.Properties.servername[0] -eq $prefer_server) {  
            $ad_printers.Remove($_.Properties.printername[0])  
            $ad_printers.Add($_.Properties.printsharename[0],$_.Properties.uncname[0])  
        }  
    } else {  
        $ad_printers.Add($_.Properties.printsharename[0],$_.Properties.uncname[0])  
    }  
}  
  
# ������� �� ��������� ��������  
# �� ���������� ������� �������� ������. �� ������� ������ � ����� ����, �� ������� ����. ������ ������� �������� � ��� �����.  
# ��� �� ���� ��� �������� - �������� �� �� �����-��������, � �� ��������� ������ � ��������  
# � ���� ������ ��� ������� ������� �� ������ ��� ��� ������� �������� � ����� �������� ���������� ������������� � AD ��������  
# � ���� ������� �� ��������� �����, � ���� ���� �������� - ������� �� ����������. ������������ ������� �� ������.  
# ��� ����� ��������� � ����������� ����������� 'do_not_delete' � ������ ������� ����� ������� �� �����  
$del_printers = gwmi win32_printer -Filter "Local='$false'"  
if ($del_printers) {      
    # system name  
    $osname = (gwmi -class Win32_OperatingSystem).Caption  
    $del_drivers = $true  
    if ($osname -match ".*2003.*") {  
        $del_drivers = $false  
    }  
    foreach ($printer in $del_printers) {  
        if (!(  
              ($printer.Comment -ne $null) -and ($printer.Comment.Contains('do_not_delete'))  
              )) {  
            $driver = $printer.DriverName  
            $printer.psbase.Delete()  
            if ($del_drivers) {  
                write "Deleteting driver $driver"  
                $rundll32="$env:windir\System32\RUNDLL32.EXE printui.dll,PrintUIEntry /dd /q /m '$driver'"  
                write $rundll32  
                invoke-expression -Command $rundll32  
            }  
        }  
    }  
}  
  
# ����� � ��������� ����������� ���������  
$printers_to_install = @()  
$adFind.Filter = "(&(objectClass=user)(!(ObjectClass=computer))(sAMAccountName=$username))"  
# Format: "printer_name:next_printer_name:last_printer_name"  
# �������� ��������� � AD � ������� ������������ � ���� "�������". ������� ��.  
$printers = ($adFind.FindOne()).Properties.physicaldeliveryofficename -split ":"  
  
if (!$printers) {  
    # no defined printers!  
    write "No defined printers!"  
    exit  
}  
# ������ � ������ ���� ��������� AD ��, ������� ����� ���.  
foreach ($printer in $printers) {  
    if ($printer.Length -ne 0) {  
        if ($ad_printers.Contains($printer)) {  
            $printers_to_install = $printers_to_install + $ad_printers.Item($printer)  
        }  
    }  
}  
  
# ���������, ���� �� ��������� ��������. ���� ���� - �� ���� ������� ��������� �������  
$local_printers = gwmi win32_printer -Filter "Local='$true'"  
$set_default = $true  
if ($local_printers) {  
    foreach ($local_printer in $local_printers) {  
        # �������� �� "������"-��������  
        if ($local_printer.Name -match ".*XPS.*") {  
            $set_default = $true  
        } elseif ($local_printer.Name -match ".*Microsoft.*") {  
            $set_default = $true  
        } else {  
            $set_default = $false  
            $local_printer.setdefaultprinter()  
            break  
        }  
    }         
}  
  
# ��������� ���������  
foreach ($printer in $printers_to_install) {  
    write "installing $printer"  
    $(New-Object -ComObject WScript.Network).AddWindowsPrinterConnection("$printer")  
}  
  
# ��������� �������� ��-���������. ��-��������� ���������� ��� �������, ��� � ���� � ������ ����� ������.  
if ($set_default) {  
    $all_pr = gwmi win32_printer -Filter "Local='$false'"  
    foreach ($printer in $all_pr) {  
        $a = $printer.ShareName  
        if ($printers[0] -eq $a) {  
            $printer.setdefaultprinter()  
        }  
    }  
}  

������ ��������� �������� ���� ��������� ����� � �������������� ��������. �������� �� ������� � ��� ������ - ���� ����������, ������ ���������.

����������� � �������� ����� ��������:

xcopy \\example.com\NETLOGON\printers\printers_chel.ps1 %temp% /Y
%windir%\system32\windowspowershell\v1.0\powershell.exe -NonInteractive -NoLogo -WindowStyle Hidden -Command ". %temp%\printers_chel.ps1"
