function Get-FileVersionCom{
	param([System.IO.FileInfo] $fileItem)
	$fso = new-object -comobject 'Scripting.FileSystemObject'
	$fso.GetFileName($fileItem)
	$fso.GetFileVersion($fileItem)
	
}

Get-FileVersionCom -fileItem 'd:\Program Files\other\Asuz.old\zlib1.dll'