####################################################
# Remote access shortcuts creation script
# v0.9
#
# Defaults:
#
#    * Create shortcuts in current directory
#    * Overwrite all shortcuts
#    * Shortcut name is "shortname" column value
#    * Shortcut comment is "desc" column value
####################################################
# Создания ярлыков удалённого управления скрипт
# версия 0.9
#
# По умолчанию:
#
#    * Ярлыки создаются в текущем каталоге
#    * Все ярлыки перезаписываются
#    * Имя ярлыка – столбец "имя"
#    * Комментарий ярлыка - столбец "описание"
####################################################

# Arguments

param (
    [switch]$noreplace, # 'Do not overwrite shortcuts on creation' default is to overwrite
    $folder = '', # 'Target folder path' default is current dir
    $source = 'source.csv', # 'Source data file path' default
    $namePolicy = 'shortname' # 'Shortcut naming policy' default
)

$csvPath = $source # Source data file path
$shPath = $folder # Target folder path
$shNoReplace = $noreplace # Do not overwrite shortcuts on creation
$shHTTPcmd = '"C:\Program Files\Internet Explorer\iexplore.exe"'
$shRDPcmd = 'mstsc.exe'
$shSSHcmd = '"C:\Program Files\PuTTY\putty.exe"'
$shTELNETcmd = 'telnet.exe'
$shNamePolicy = $namepolicy # Shortcut naming policy

function createShctFile($shText,$shCmd,$shArgs, $desc = '')
{ # creating shortcut file
    $shPathSh = "$shPath\$shText.lnk"
    if ( (test-path -path $shPathSh) -and $shNoReplace ) {return}
    $shct = $oshell.CreateShortcut($shPathSh)
    $shct.TargetPath = $shCmd
    $shct.Arguments = $shArgs
    $shct.Description = $desc
    $shct.Save()
}

function createShct($shortname,$desc='',$addr,$method)
{ # preparing shortcurt parameters
    # Shortcut name
    $shText = $shortname
    if (!$shortname)
    {
        write-host '(i) No shortcut name defined'
        return
    }
    switch ($shNamePolicy) {
        'shortname' {
            $shText = $shortname
        }
        'shortname_addr' {
            $shText = "$shortname $addr"
        }
        'addr_shortname' {
            $shText = "$addr $shortname"
        }
        'shortname_lastoct' {
            $octs = ($addr -split '\.')
            if ($octs[3]) {$shText += ' ' + $octs[3]}
        }
        'shortname_last2octs' {
            $octs = ($addr -split '\.')
            if ($octs[3]) {$shText += ' ' + $octs[2]+ '.' + $octs[3]}
        }
    }
    
    #Shortcut command
    $shArgs = ''
    switch ($method) {
        'http' {
            $shCmd = $shHTTPCmd
            $shArgs = "http://$addr"            
        }
        'https' {
            $shCmd = $shHTTPCmd
            $shArgs = "https://$addr"            
        }
        'rdp' {
            $shCmd = $shRDPCmd
            $shArgs = "/v:$addr"
        }
        'ssh' {
            $shCmd = $shSSHcmd
            $shArgs = $addr
        }
        'telnet' {
            $shCmd = $shTELNETcmd
            $shArgs = $addr
        }        
    }
    createShctFile -shText $shText  -shCmd $shCmd -shArgs $shArgs -desc $desc
}

##### Main

# Init

$oshell = New-Object -comObject WScript.Shell
$basePath = (get-location).path # Working dir
[System.IO.Directory]::SetCurrentDirectory($basePath) # Set working dir to script working dir

# Env check

if (!(test-path -pathtype leaf -path $csvPath))
{ # Cheking for source CSV path
    write-host "(!) Path to source CSV not found: $csvPath"
    exit
}
if (!($shPath)) {$shPath = $basePath }
if (!(test-path -pathtype container -path $shPath))
{ # Cheking for target folder path
    write-host "(!) Path for shortcuts not found: $shPath"
    exit
}

# Run

$csv = get-content $csvPath | Convertfrom-CSV -UseCulture
foreach ($str in $csv)
{
    $shrt = $str.shortname
    if ($str.имя) {$shrt = $str.имя}
    $addr = $str.addr
    if ($str.адрес) {$addr = $str.адрес}
    $accs = $str.method
    if ($str.доступ) {$accs = $str.доступ}
    $desc = $str.desc
    if ($str.описание) {$desc = $str.описание}
    createShct -shortname $shrt -desc $desc -addr $addr -method $accs
}