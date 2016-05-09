# Ближайший до пользователя принт-сервер. Просто некоторые принтеры подключены к нескольких сервакам. Зачем? Никто не знает.  
$prefer_server = "chel2.example.com"  
# Подрубаемся к домену  
$domain = "LDAP://dc=example,dc=com"  
$root = New-Object DirectoryServices.DirectoryEntry $domain  
$adFind = New-Object Directoryservices.DirectorySearcher  
$adFind.SearchRoot = $root  
# Возьмем имя пользователя из окружения  
$username = $env:username  
  
# Ничего не делать, если скрипт выполняется на win2k3 и у пользователя в DN есть Full Users (То есть фулл юзверь подключился к терминал-серверу)  
# Т.к. у нас в домене есть терминальщики и полноценники, то полноценникам не надо подключать принтера в терминальную сессию  
# Т.к. они у нас в разных OU, проверку выполняем по DN.  
$adFind.Filter = "(&(objectClass=user)(!(ObjectClass=computer))(sAMAccountName=$username))"  
$user = $adFind.FindOne()  
if ($user.Path.Contains("Full_Users")) {  
    $osname = (gwmi -class Win32_OperatingSystem).Caption     
    if ($osname -match ".*2003.*") {              
            exit(0);  
    }  
}  
  
# Перечисление всех доступных принтеров  
$ad_printers = @{}  
$adFind.Filter = "(objectClass=printqueue)"  
$adFind.FindAll() | Sort-Object -Property Properties.servername | foreach-object {  
    if ($ad_printers.Contains($_.Properties.printername[0])) {  
        # Добавить шару принтера на предпочитаемом сервере. Удалить на непредпочитаемом  
        if ($_.Properties.servername[0] -eq $prefer_server) {  
            $ad_printers.Remove($_.Properties.printername[0])  
            $ad_printers.Add($_.Properties.printsharename[0],$_.Properties.uncname[0])  
        }  
    } else {  
        $ad_printers.Add($_.Properties.printsharename[0],$_.Properties.uncname[0])  
    }  
}  
  
# Удалить не локальные принтеры  
# На терминалах удалять драйвера стрёмно. На обычных компах в общем тоже, но сказали надо. Значит удаляём драйверы в том числе.  
# Так же есть еще проблема - принтеры не на принт-серверах, а на локальных компах в филиалах  
# В этом случае при запуске скрипта он удалит нах все сетевые принтаки и будет пытаться подключить перечисленные в AD принтеры  
# А если принтак на локальном компе, и этот комп выключен - принтак не поставится. Пользователь звереет на глазах.  
# Для таких принтеров в комментарии прописываем 'do_not_delete' и скрипт удалять такой принтер не будет  
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
  
# Поиск и установка назначенных принтеров  
$printers_to_install = @()  
$adFind.Filter = "(&(objectClass=user)(!(ObjectClass=computer))(sAMAccountName=$username))"  
# Format: "printer_name:next_printer_name:last_printer_name"  
# Принтеры прописаны в AD у каждого пользователя в поле "Комната". Получим их.  
$printers = ($adFind.FindOne()).Properties.physicaldeliveryofficename -split ":"  
  
if (!$printers) {  
    # no defined printers!  
    write "No defined printers!"  
    exit  
}  
# Найдем в списке всех принтеров AD те, которые нужны нам.  
foreach ($printer in $printers) {  
    if ($printer.Length -ne 0) {  
        if ($ad_printers.Contains($printer)) {  
            $printers_to_install = $printers_to_install + $ad_printers.Item($printer)  
        }  
    }  
}  
  
# Проверить, есть ли локальные принтеры. Если есть - не надо ставить дефолтный принтер  
$local_printers = gwmi win32_printer -Filter "Local='$true'"  
$set_default = $true  
if ($local_printers) {  
    foreach ($local_printer in $local_printers) {  
        # Проверка на "псевдо"-принтеры  
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
  
# Установка принтеров  
foreach ($printer in $printers_to_install) {  
    write "installing $printer"  
    $(New-Object -ComObject WScript.Network).AddWindowsPrinterConnection("$printer")  
}  
  
# Установка принтера по-умолчанию. По-умолчанию пропишется тот принтер, что в поле у юзвера стоит первым.  
if ($set_default) {  
    $all_pr = gwmi win32_printer -Filter "Local='$false'"  
    foreach ($printer in $all_pr) {  
        $a = $printer.ShareName  
        if ($printers[0] -eq $a) {  
            $printer.setdefaultprinter()  
        }  
    }  
}  

Скрипт наверняка содержит пару миллионов багов и непредвиденных ситуаций. Писалось на коленке и как обычно - если заработало, значит нормально.

Запускается у клиентов таким батником:

xcopy \\example.com\NETLOGON\printers\printers_chel.ps1 %temp% /Y
%windir%\system32\windowspowershell\v1.0\powershell.exe -NonInteractive -NoLogo -WindowStyle Hidden -Command ". %temp%\printers_chel.ps1"
