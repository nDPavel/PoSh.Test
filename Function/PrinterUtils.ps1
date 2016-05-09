########################################################
# PrinterUtils.ps1
# Version 0.1.0.0
#
# Functions for advanced printer management
#
# Vadims Podans (c) 2008
# http://www.sysadmins.lv/
########################################################

# ���������� �������, ������� ��������������� �������� ��� �������� �������� ������ ACL
# � ��������� ��������.
function _PrinterUtils_Get-Code ($Write) {
    switch ($Write.ReturnValue) {
        "0" {"Success"}
        "2" {"Access Denied"}
        "8" {"Unknown Error"}
        "9" {"The user does not have adequate privileges to execute the method"}
        "21" {"A parameter specified in the method call is invalid"}
        default {"Unknown error $Write.ReturnValue"}
    }
}

# ������� ��������� ������ (�������) ACL �������� ��� ���� ���������
function Get-Printer ($Computer = ".", $name) {
    # ���� ���������� $name ������, �� ������������ ������ ���� ��������� ���������
    if ($name) {
        $Printers = gwmi Win32_Printer -ComputerName $Computer -Filter "name = '$name'"
    } else {
        $Printers = gwmi Win32_Printer -ComputerName $Computer -Filter "local = '$True'"
    }
    # ���������� ������� ������� ACL
    $PrinterInfo = @()
    # ���������� ������ ACL �� ������� �������� ������� ������� ACL
    foreach ($Printer in $Printers) {
        if ($printer) {
            # � ���������� $SD �������� ���������� ������������ ��� ������� �������� � ������ ������� ACE (DACL)
            # � ��������� � $PrinterInfo
            $SD = $Printer.GetSecurityDescriptor()
            $PrinterInfo += $SD.Descriptor.DACL | %{
                $_ | Select @{e = {$Printer.SystemName}; n = 'Computer'},
                @{e = {$Printer.name}; n = 'Name'},
                AccessMask,
                AceFlags,
                AceType,
                @{e = {$_.trustee.Name}; n = 'User'},
                @{e = {$_.trustee.Domain}; n = 'Domain'},
                @{e = {$_.trustee.SIDString}; n = 'SID'}
            }
        } else {
            Write-Warning "Specified printer not found!"
        }
    }
    # ������ �������� �� ACL �� ����� ������� ��� ����������� ������ �� ��������
    $PrinterInfo
}

# ������� ������ � ACL ��������. ��� �� ��������� ������� ����������,
# � ������ ��������� ������ � ���������
function Set-Printer {
    # �� ��������� �������� ������ ACE �� �������� ���������
    $PrinterInfo = @($Input)
    # ��������� ���������� ������ �� ����� �������� � ������ �� ����� ����� ��
    # ��������� ������ ACL ������ ��������
    $PrinterInfo | Select -Unique Computer, Name | % {
        $Computer = $_.Computer
        $name = $_.name
        # ������ ����� ������� ����������� �������
        $SD = ([WMIClass] "Win32_SecurityDescriptor").CreateInstance()
        $ace = ([WMIClass] "Win32_Ace").CreateInstance()
        $Trustee = ([WMIClass] "Win32_Trustee").CreateInstance()
        # ������ ��������� ������ ACE ��� ���������������� ������ ACL �� PrinterInfo �
        # ��������� ����� SecurityDescriptor
        $PrinterInfo | ? {$_.Computer -eq $Computer -and $_.name -eq $name} | % {
            $SID = new-object security.principal.securityidentifier($_.SID)
            [byte[]] $SIDArray = ,0 * $SID.BinaryLength
            $SID.GetBinaryForm($SIDArray,0)
            $Trustee.Name = $_.user
            $Trustee.SID = $SIDArray
            $ace.AccessMask = $_.AccessMask
            $ace.AceType = $_.AceType
            $ace.AceFlags = $_.AceFlags
            $ace.trustee = $Trustee
            # ����� ACE �������� ��������� � DACL ����������� ������������
            $SD.DACL += @($ace.psobject.baseobject)
            # ������������� ���� SE_DACL_PRESENT, ��� ����� �������� � ���, ��� �� ��������
            # ������ DACL � ������ �����
            $SD.ControlFlags = 0x0004
        }
        # ����� ������ ������ ACL ��� �������� �������� ������, �������� ��� �������� ��������
        $Printer = gwmi Win32_Printer -ComputerName $Computer -Filter "name = '$name'"
        # �����������, ��� ������� ��� ������ ACL ������ � ������������ ������.
        # � ��������� ������ ������ ACL ������������
        if ($Printer) {
            $Write = $Printer.SetSecurityDescriptor($SD)
            Write-Host "Processing current printer: $name"
            _PrinterUtils_Get-Code $Write
        } else {
            Write-Warning "Skipping non-present printer: $name"
        }
    }
}

# ���������� �������, ������� ������ ��������� ������ ������������ � ������� ����
# � ���������� ������ � ���������� ������� ��� ����������� ��������������
function _Create-SDObject ( $user, $AceType, $AccessMask) {
    # �������������� ���������� ���� ���� � �������� ��������
    $masks = @{ManagePrinters = 983052; ManageDocuments = 983088; Print = 131080;
        TakeOwnership = 524288; ReadPermissions = 131072; ChangePermissions = 262144}
    $types = @{Allow = 0; Deny = 1}
    # �������� ����������� ������� ��� �������. ��� ��������� ��������� ����������
    # ���� ��������� �������� Computer, ������� ����� ��������� �� Get-Printer �����������
    # ��������. ��� ����� �������������� �������� ���������� ����� ����������, ���
    # ��������� �������, �� ��������� ��� ����������� ������
    $AddInfo = New-Object System.Management.Automation.PSObject
    $AddInfo | Add-Member NoteProperty Computer ([PSObject]$null)
    $AddInfo | Add-Member NoteProperty Name ([PSObject]$null)
    $AddInfo | Add-Member NoteProperty AccessMask ([uint32]$null)
    $AddInfo | Add-Member NoteProperty AceFlags ([uint32]$null)
    $AddInfo | Add-Member NoteProperty AceType ([uint32]$null)
    $AddInfo | Add-Member NoteProperty User ([PSObject]$null)
    $AddInfo | Add-Member NoteProperty Domain ([PSObject]$null)
    $AddInfo | Add-Member NoteProperty SID ([PSObject]$null)
    # ���������� ������� �������, ������� ���� ������� � �������� ���������� ������ ������� � �������
    # ������� � ���������� �������
    $AddInfo.Name = $name
    $AddInfo.User = $user
    $AddInfo.SID = (new-object security.principal.ntaccount $user).translate([security.principal.securityidentifier])
    $AddInfo.AccessMask = $masks.$AccessMask
    $AddInfo.AceType = $types.$AceType
    if ($masks.$AccessMask -eq 983088) {$AddInfo.AceFlags = 9}
    $AddInfo
}

# ������� ��� ��������� ���������� �� �������. ��� � �������������, ������� ACL ���������
# �� ���� ������� � ��������������� ������ ���� �����������/������ � ������ ManagePrinters
function Set-PrinterPermission ($user) {
    # ����������� ������ � ���������
    $PrinterInfo = @($Input)
    $AddInfo = _Create-SDObject $user Allow ManagePrinters
    # � ���� ����� ������������ �� ������ ��� ����� ��������� � ��� ������� �� ���
    # ������������ ��������� � ���������� ������������ � ��������� ������� ACE �� ACL ��������
    # ��� ����� �� ����, ��� ������� ����� $PrinterInfo �� ��������� �� ��������� �� ������
    foreach ($Printer in ($PrinterInfo | select -Unique Computer, Name)) {
        $AddInfo.Computer = $Printer.Computer
        $AddInfo.Name = $Printer.name
        $AddInfo | Set-Printer
    }
}

# ������� ���������� ������������/������ � ��������� ������ ACL ��������. �������� ������� ��
# ����������� ��������, ��� ��� ������� �������� ACE �� ���������������, � �����������
function Add-PrinterPermission ($user, $AceType, $AccessMask) {
    $PrinterInfo = @($Input)
    $AddInfo = _Create-SDObject $user $AceType $AccessMask
    foreach ($Printer in ($PrinterInfo | select -Unique Computer, Name)) {
        $AddInfo.Name = $Printer.name
        $AddInfo.Computer = $Printer.Computer
        # ��� ���� ������� �� �� ������ ���� ��������� ���������� ���������� ������ �������
        $PrinterInfoNew = $PrinterInfo | ?{$_.name -eq $Printer.name}
        # � � ����� ������ ACL ��������� ����� ACE
        $PrinterInfoNew += $AddInfo
        # � ����� �� ������
        $PrinterInfoNew | Set-Printer
    }
}

# ������� ��� �������� ACE ������������/������ �� ACL
function Remove-PrinterPermission ($user) {
    $Printers = @($Input)
    # ������ ���� ������ ACL, ������� ������ �� ��������� � ���������� ������ ��� ACE,
    # � ������� ���������� ��������� � ���������� ������������/������ � ��������� ACE ������� � ACL
    $printers | ? {$_.user -ne $user} | Set-Printer
}

function New-NetworkPrinter ($Computer, $name) {
    ([wmiclass]'Win32_Printer').AddPrinterConnection("\\$Computer\$name")
}

function Remove-NetworkPrinter ($name) {
    if ($name) {
        (gwmi Win32_Printer -Filter "sharename='$name'").delete()
    } else {
        (gwmi Win32_Printer -Filter "local='$false'").delete()
    }
}

function Set-DefaultPrinter ($name) {
    if (!$name) {
        Write-Warning "You must to specify printer name. Operation aborted!"
    } else {
        if (gwmi win32_Printer -Filter "name='$name'") {
            $SetDefault = (gwmi win32_Printer -Filter "name='$name'").SetDefaultPrinter()
            switch ($SetDefault.ReturnValue) {
                "0" {Write-Host "Now your default printer is $name"}
                default {Write-Warning "Some error occur"}
            }
        } else {
            Write-Warning "Specified printer not exist!"
        }
    }
}

function Get-PrinterInfo ($Computer = ".", $name) {
    # ����� � ��������� �������� ��� ������ ����� �������, ��� � ���������� ����� ��������. 
    if ($name) {
        gwmi Win32_Printer -ComputerName $Computer -Filter "name='$name'" | select *
    } else {
        gwmi Win32_Printer -ComputerName $Computer
    }
}

function New-PrinterShare ($Computer = ".", $name, $ShareName) {
    $Printer = gwmi win32_Printer -ComputerName $Computer -Filter "name='$name'"
    if ($Printer) {
        $Printer.shared = $True
        $Printer.ShareName = $ShareName
        $Printer.put()
    } else {
        Write-Warning "Specified printer not exist!"
    }
}

function Remove-PrinterShare ($Computer = ".", $name) {
    if ($name) {
        $filter = "name = '$name'"
    } else {
        $filter = "local = '$false'"
    }
    gwmi Win32_Printer -ComputerName $Computer -Filter $filter | % {
        $_.shared = $false
        $_.put()
    }
}