Function New-Shortcut {
	Param([Parameter(Mandatory,
					 ValueFromPipeline)][System.String]$To)
	if ($To.EndsWith(':')) { $To += [char]92 }
	try { $target = Get-Item -Force -LiteralPath $To -ea 'Stop' } catch [Exception]{ throw }
$IsDirectory = $target.Mode[0] -eq [char]0x64
$shellObj = New-Object -ComObject "Wscript.Shell"
$shName = $target.BaseName
	if ($IsDirectory) {
	if ($shName -like '*:\') {
$driveLetter = $shName[0]
$volumeLabel = (Get-Volume -DriveLetter $driveLetter).FileSystemLabel
$shName = "$volumeLabel ($driveLetter)"
					}
						}
$shortcut = $shellObj.CreateShortcut("$HOME\Desktop\$shName.lnk")
$shortcut.TargetPath = $target.FullName
	if (-not $IsDirectory) {
$shortcut.WorkingDirectory = $target.Directory.FullName
	}
$shortcut.Save()
}