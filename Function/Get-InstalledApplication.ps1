<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	15.02.2016 13:40
	 Created by:   	pavel.linchik
	 Organization: 	
	 Filename:     	Get-InstalledApplication.ps1 
                    or
                    Get-InstalledApplication.psm1
	===========================================================================
	.DESCRIPTION
		PS > Get-InstalledApplication -ComputerName dc1,dc2
        PS > "dc1","dc2" |  Get-InstalledApplication

#>

Function Get-InstalledApplication
{
    [CmdletBinding()]
    param (
    [Switch]$Credential, 
    [parameter(ValueFromPipeline=$true)]
    [String[]]$ComputerName = $env:COMPUTERNAME
    )
 
    begin {$key = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"}
 
    process 
    {   
        $ComputerName | ForEach-Object {
        $Comp = $_
        if (!$Credential)
        {
            $registry=[microsoft.win32.registrykey]::OpenRemoteBaseKey('Localmachine',$Comp)
            $registrykey=$registry.OpenSubKey([regex]::Escape($key)) 
            $SubKeys=$registrykey.GetSubKeyNames()
 
            Foreach ($i in $SubKeys) 
            { 
                $NewSubKey=[regex]::Escape($key)+"\\"+$i
                $ReadUninstall=$registry.OpenSubKey($NewSubKey) 
                $Name=$ReadUninstall.GetValue("DisplayName") 
                $Date=$ReadUninstall.GetValue("InstallDate")
                $Publ=$ReadUninstall.GetValue("Publisher")
                New-Object PsObject -Property @{"Name"=$Name;"Date"=$Date;"Publisher"=$Publ;"Computer"=$Comp} | Where {$_.Name}
            }
        }
 
        else
        {
            $Cred = Get-Credential
            $connect = New-Object System.Management.ConnectionOptions
            $connect.UserName = $Cred.GetNetworkCredential().UserName
            $connect.Password = $Cred.GetNetworkCredential().Password
 
            $scope = New-Object System.Management.ManagementScope("\\$Comp\root\default", $connect)
            $path = New-Object System.Management.ManagementPath("StdRegProv")
            $registry = New-Object System.Management.ManagementClass($scope,$path,$null)
            $inParams = $registry.GetMethodParameters("EnumKey")
            $inParams.sSubKeyName = $key
            $outParams = $registry.InvokeMethod("EnumKey", $inParams, $null)
 
            foreach ($i in $outparams.sNames)
            {
                $inParams = $registry.GetMethodParameters("GetStringValue")
                $inParams.sSubKeyName = $key + $i
                    $temp = "DisplayName", "InstallDate", "Publisher" |
                    ForEach-Object {
                    $inParams.sValueName = $_
                    $outParams = $registry.InvokeMethod("GetStringValue", $inParams, $null)
                    $outParams.sValue
                } 
                New-Object PsObject -Property @{"Name"=$temp[0];"Date"=$temp[1];"Publisher"=$temp[2];"Computer"=$Comp} | Where {$_.Name}
            }
        }
     }
  }
}



Get-InstalledApplication -ComputerName "CC-vzh-40"