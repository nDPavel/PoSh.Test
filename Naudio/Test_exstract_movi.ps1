
<#
выдергиваем свуковую дорожку в из mp4 и переводим её в wav

#>

add-type -Path "D:\Job\scripts\PowerShell\Projects\Prosluhka\soft\NAudio\NAudio.dll"
Add-Type -Path "D:\Job\scripts\PowerShell\Projects\Prosluhka\soft\NAudio\NAudio.WindowsMediaFormat.dll"

[String]$filename = "d:\Job\scripts\PowerShell\Function\Naudio\test.mp4"
[String]$filename2 = "d:\Job\scripts\PowerShell\Function\Naudio\Test2.wav"
#создаем новый обьект исходного файла 
$Reader = New-Object NAudio.Wave.AudioFileReader($filename)
#вытаскиваем звуковую дорожку
[NAudio.Wave.WaveFileWriter]::CreateWaveFile16($filename2, $Reader)
#Проверяем создался ли файли
Test-Path -Path $filename2

