add-type -Path "D:\Job\scripts\PowerShell\Projects\Prosluhka\soft\NAudio\NAudio.dll"
Add-Type -Path "D:\Job\scripts\PowerShell\Projects\Prosluhka\soft\NAudio\NAudio.WindowsMediaFormat.dll"

$devices = new-object NAudio.CoreAudioApi.MMDeviceEnumerator
$wave = New-Object NAudio.Wave.wri
$FileFormat = New-Object NAudio.FileFormats



$defaultDevice = $devices.GetDefaultAudioEndpoint([NAudio.CoreAudioApi.DataFlow]::Capture, [NAudio.CoreAudioApi.Role]::Communications)
$defaultDevice.FriendlyName
$defaultDevice.DeviceFriendlyName
$defaultDeviceId = $defaultDevice.ID -replace '{.+}\.{(.+)}$', '$1'
$defaultDeviceId

<#
write-host "Все устройства"
    $DevicesAll = $devices.EnumerateAudioEndPoints([NAudio.]::All, [NAudio.CoreAudioApi.DeviceState]::active)
    $DevicesAll | select-object -Property DeviceFriendlyName,State,DataFlow,ID | ft -AutoSize
#>
