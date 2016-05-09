
add-type -Path "D:\Job\scripts\PowerShell\Projects\Prosluhka\soft\NAudio\NAudio.dll"
Add-Type -Path "D:\Job\scripts\PowerShell\Projects\Prosluhka\soft\NAudio\NAudio.WindowsMediaFormat.dll"

$devices = new-object NAudio.CoreAudioApi.MMDeviceEnumerator

$defaultDevice = $devices.GetDefaultAudioEndpoint([NAudio.CoreAudioApi.DataFlow]::All, [NAudio.CoreAudioApi.DeviceState]::All)
$defaultDevice.FriendlyName
$defaultDevice.DeviceFriendlyName
$defaultDeviceId = $defaultDevice.ID -replace '{.+}\.{(.+)}$', '$1'
$defaultDeviceId
<#
Write-Host "Наушники или колонки"
$sound   = $devices.GetDefaultAudioEndpoint([NAudio.CoreAudioApi.DataFlow]::Render, [NAudio.CoreAudioApi.Role]::Console)
$soundID = $sound.ID -replace '{.+}\.{(.+)}$', '$1'
$sound | select-object -Property DeviceFriendlyName,State,DataFlow
$soundID
#>
#comunication -устройство связи
#console - устройство по умолчанию
<#
write-host "Микрофон"
$mic = $devices.GetDefaultAudioEndpoint([NAudio.CoreAudioApi.DataFlow]::All, [NAudio.CoreAudioApi.Role]::Communications)
$micID = $mic.ID -replace '{.+}\.{(.+)}$', '$1'
$mic | select-object -Property DeviceFriendlyName,ID,State,DataFlow
$micID 
#cadb401c-9d5d-44ab-b712-0ebfc1c8db4b
#>


write-host "Все устройства"
#$DevicesAll = $devices.EnumerateAudioEndPoints([NAudio.CoreAudioApi.DataFlow]::All, [NAudio.CoreAudioApi.DeviceState]::Disabled)
#$DevicesAll # | select-object -Property DeviceFriendlyName,State,DataFlow,ID | ft -AutoSize


