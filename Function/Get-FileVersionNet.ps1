function get-FileVersionNet {
	param([System.IO.FileInfo] $fileItem)
			$verInfo = $fileItem.VersionInfo
			$verInfo.ProductVersion
			#«{0}.{1}.{2}.{3}» -f 
			<#
			$verInfo.FileMajorPart, 
			$verInfo.FileMinorPart,	
			$verInfo.FileBuildPart	
			$verInfo.FilePrivatePart
			#>
}
