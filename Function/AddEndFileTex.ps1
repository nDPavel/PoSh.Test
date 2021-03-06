<#	.DESCRIPTION AddEndFileTex
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	18.01.2016 16:58
	 Created by:   	pavel.linchik
	 Organization: 	vivadengi
	 Filename:     	Get-HostName.ps1
	===========================================================================
	.DESCRIPTION
	Функция дозаписования файла 
	.StarParametrs
	AddEndFileTex -Txt 'dfdf' -path
#>

function AddEndFileTex{
	Param($TXT, $Path )
		$text = ("`r`n" + $TXT)
	#Преобразуем в массив байтов с кодировкой cp-1251
		$TextBytes = [Text.Encoding]::GetEncoding("windows-1251").GetBytes($text)
	#Укажем требуемые разрешения
		$fs = New-Object IO.FileStream($Path,[IO.FileMode]::Open,[Security.AccessControl.FileSystemRights]::AppendData,[IO.FileShare]::Read,8,[IO.FileOptions]::None)
	#Добавим данные
			$fs.Write($TextBytes,0,$TextBytes.Count)
	#Закроем текущий поток
			$fs.Close()	
		
	}

