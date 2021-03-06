<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.81
	 Created on:   	18.01.2016 16:58
	 Created by:   	pavel.linchik
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
function getInstalledProgramsInformation()
{
	try
	{
		## Setting the save location - this can be updated to save it to a passed in parameter
		$Invocation = (Get-Variable MyInvocation -Scope Script).Value
		$ScriptPath = Split-Path -Parent $Invocation.MyCommand.Path;
		$SavePath = $ScriptPath + "\Programs.xml";
		
		Compile-Csharp $strCSharpCode;
		
		Write-Host "Getting Program Information from the MSI Database";
		try { $global:nodePrograms = [NSProgramInformation.ProgramInfo]::getProgramInfo(); }
		catch { };
		
		$global:xmlDoc = New-Object System.Xml.XmlDataDocument;
		
		if ($global:nodePrograms -eq $null)
		{
			$global:nodePrograms = $global:xmlDoc.CreateElement("Programs");
		}
		else
		{
			$global:xmlDoc.AppendChild($global:xmlDoc.ImportNode($global:nodePrograms, $true));
		}
		
		$global:nodePrograms = $global:xmlDoc.DocumentElement;
		
		Write-Host "Getting Windows Patch Information";
		addWindowsPatchInfo;
		
		$hiveHKLM = [Microsoft.Win32.RegistryHive]::LocalMachine;
		$hiveHKCU = [Microsoft.Win32.RegistryHive]::CurrentUser;
		
		Write-Host "Getting Program Information from the Registry";
		addProgramsFromRegistry $hiveHKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall" "HKLM";
		addProgramsFromRegistry $hiveHKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall" "HKCU";
		addProgramsFromRegistry $hiveHKLM "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "WOW_HKLM";
		addProgramsFromRegistry $hiveHKCU "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "WOW_HKCU";
		
		Write-Host "Getting Patch Information from the Registry";
		addPatchesToRegistryPrograms $hiveHKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall" "HKLM";
		addPatchesToRegistryPrograms $hiveHKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall" "HKCU";
		addPatchesToRegistryPrograms $hiveHKLM "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "WOW_HKLM";
		addPatchesToRegistryPrograms $hiveHKCU "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" "WOW_HKCU";
		
		Write-Host "Writing out xml to $SavePath";
		$global:xmlDoc.Save($SavePath);
		Write-Host "Done!";
	}
	catch
	{
		$Message = "Error in getInstalledProgramsInformation(): " + $_.Exception.Message;
		Write-Host $Message -BackgroundColor Red;
	}
}

function addWindowsPatchInfo()
{
	try
	{
		$windowsProgramNode = $global:xmlDoc.CreateElement("Program");
		$global:nodePrograms.AppendChild($windowsProgramNode);
		
		[System.Xml.XmlNode]$ChildNode = $global:xmlDoc.CreateElement("ProgramName");
		$ChildNode.psbase.InnerText = "Microsoft Windows";
		$windowsProgramNode.AppendChild($ChildNode);
		
		$ChildNode = $global:xmlDoc.CreateElement("InfoSource");
		$ChildNode.psbase.InnerText = "Win32_QuickFixEngineering";
		$windowsProgramNode.AppendChild($ChildNode);
		
		$ChildNode = $global:xmlDoc.CreateElement("ARPDisplay");
		$ChildNode.psbase.InnerText = "TRUE";
		$windowsProgramNode.AppendChild($ChildNode);
		
		[System.Xml.XmlNode]$nodePatches = $global:xmlDoc.CreateElement("ProgramPatches");
		$windowsProgramNode.AppendChild($nodePatches);
		
		foreach ($Patch in (get-wmiobject Win32_QuickFixEngineering))
		{
			[System.Xml.XmlNode]$PatchNode = $global:xmlDoc.CreateElement("ProgramPatch");
			
			[System.Xml.XmlNode]$ChildNode = $global:xmlDoc.CreateElement("PatchName");
			$ChildNode.psbase.InnerText = $Patch.HotFixID;
			$PatchNode.AppendChild($ChildNode);
			
			$ChildNode = $global:xmlDoc.CreateElement("Caption");
			$ChildNode.psbase.InnerText = $Patch.Caption;
			$PatchNode.AppendChild($ChildNode);
			
			$ChildNode = $global:xmlDoc.CreateElement("PatchInstallDate");
			$ChildNode.psbase.InnerText = $Patch.InstalledOn;
			$PatchNode.AppendChild($ChildNode);
			
			if (![string]::IsNullOrEmpty($Patch.InstalledBy))
			{
				$ChildNode = $global:xmlDoc.CreateElement("PatchInstalledBy");
				$ChildNode.psbase.InnerText = $Patch.InstalledBy;
				$PatchNode.AppendChild($ChildNode);
			}
			
			$nodePatches.AppendChild($PatchNode);
		}
	}
	catch
	{
		$Message = "Error in addWindowsPatchInfo(): " + $_.Exception.Message;
		Write-Host $Message -BackgroundColor Red;
	}
}

function addProgramsFromRegistry([Microsoft.Win32.RegistryHive]$registryHive, [string]$strKey, [string]$strSource)
{
	try
	{
		if ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey) -ne $null)
		{
			[String[]] $arrKeyNames = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey).GetSubKeyNames();
			if ($arrKeyNames.Length -gt 0)
			{
				foreach ($strSubKey in $arrKeyNames)
				{
					if ($global:nodePrograms.SelectSingleNode("Program/ProgramID[.='" + $strSubKey + "']") -eq $null)
					{
						$strDisplayName = [string]::Empty;
						$strDisplayVersion = [string]::Empty;
						$strInstallDate = [string]::Empty;
						
						if ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("DisplayName") -ne $null)
						{
							$strDisplayName = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("DisplayName").ToString();
						}
						if ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("DisplayVersion") -ne $null)
						{
							$strDisplayVersion = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("DisplayVersion").ToString();
						}
						if ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("InstallDate") -ne $null)
						{
							$strInstallDate = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("InstallDate").ToString();
						}
						
						if (![string]::IsNullOrEmpty($strDisplayName))
						{
							$strParentDisplayName = [string]::Empty;
							$keyParentDisplayName = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("ParentDisplayName");
							if ($keyParentDisplayName -ne $null)
							{
								$strParentDisplayName = $keyParentDisplayName.ToString();
							}
							
							if ([string]::IsNullOrEmpty($strParentDisplayName))
							{
								[System.Xml.XmlNode]$Program = $global:xmlDoc.CreateElement("Program");
								
								[System.Xml.XmlNode]$nodeChild = $global:xmlDoc.CreateElement("ProgramName");
								$nodeChild.InnerText = $strDisplayName;
								$Program.AppendChild($nodeChild);
								
								$nodeChild = $global:xmlDoc.CreateElement("ProgramVersion");
								$nodeChild.InnerText = $strDisplayVersion;
								$Program.AppendChild($nodeChild);
								
								$nodeChild = $global:xmlDoc.CreateElement("ProgramInstallDate");
								$nodeChild.InnerText = getProgramInstallDate $strInstallDate $strDisplayName;
								$Program.AppendChild($nodeChild);
								
								$nodeChild = $global:xmlDoc.CreateElement("InfoSource");
								$nodeChild.InnerText = $strSource;
								$Program.AppendChild($nodeChild);
								
								if ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("SystemComponent") -ne $null)
								{
									if ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("SystemComponent").ToString() -eq "1")
									{
										$nodeChild = $global:xmlDoc.CreateElement("ARPDisplay");
										$nodeChild.InnerText = "FALSE";
										$Program.AppendChild($nodeChild);
									}
									else
									{
										$nodeChild = $global:xmlDoc.CreateElement("ARPDisplay");
										$nodeChild.InnerText = "TRUE";
										$Program.AppendChild($nodeChild);
									}
								}
								else
								{
									$nodeChild = $global:xmlDoc.CreateElement("ARPDisplay");
									$nodeChild.InnerText = "TRUE";
									$Program.AppendChild($nodeChild);
								}
								
								$global:nodePrograms.AppendChild($Program);
							}
						}
					}
				}
			}
		}
	}
	catch
	{
		$Message = "Error in addProgramsFromRegistry(): " + $_.Exception.Message;
		Write-Host $Message -BackgroundColor Red;
	}
}

function getProgramInstallDate([string]$strInstallDate, [string]$strDisplayName)
{
	$InstallDate = [string]::Empty;
	if (![string]::IsNullOrEmpty($strInstallDate))
	{
		try { $InstallDate = [System.DateTime]::Parse($strInstallDate).ToShortDateString(); }
		catch { $InstallDate = $strInstallDate; }
	}
	else
	{
		[System.Xml.XmlNode]$Program = $global:nodePrograms.SelectSingleNode("Program/ProgramName[.='" + $strDisplayName + "']");
		if ($Program -ne $null)
		{
			if ($Program.ParentNode["ProgramInstallDate"] -ne $null)
			{
				$InstallDate = $Program.ParentNode["ProgramInstallDate"].InnerText;
				try { $InstallDate = [System.DateTime]::Parse($InstallDate).ToShortDateString(); }
				catch { }
			}
		}
	}
	return $InstallDate;
}

function addPatchesToRegistryPrograms([Microsoft.Win32.RegistryHive]$registryHive, [string]$strKey, [string]$strSource)
{
	try
	{
		if ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey) -ne $null)
		{
			[String[]]$arrKeyNames = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey).GetSubKeyNames();
			if ($arrKeyNames.Length -gt 0)
			{
				foreach ($strSubKey in $arrKeyNames)
				{
					if ($global:nodePrograms.SelectSingleNode("Program/ProgramID[.='" + $strSubKey + "']") -eq $null)
					{
						$strSysComponent = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("SystemComponent");
						
						if ($strSysComponent -eq $null)
						{
							$strDisplayName = [string]::Empty;
							$strParentDisplayName = [string]::Empty;
							
							if ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("DisplayName") -ne $null)
							{
								$strDisplayName = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("DisplayName").ToString();
							}
							if ([Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("ParentDisplayName") -ne $null)
							{
								$strParentDisplayName = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($registryHive, [System.Environment]::MachineName).OpenSubKey($strKey + "\\" + $strSubKey).GetValue("ParentDisplayName").ToString();
							}
							
							if (![string]::IsNullOrEmpty($strParentDisplayName) -and ![string]::IsNullOrEmpty($strDisplayName))
							{
								[System.Xml.XmlNodeList]$nlParent = $global:nodePrograms.SelectNodes("Program/ProgramName[.='" + $strParentDisplayName + "']");
								foreach ($nParent in $nlParent)
								{
									if ($nParent.ParentNode["InfoSource"].InnerText -ne "MSI")
									{
										[System.Xml.XmlNode]$Program = $nParent.ParentNode;
										[System.Xml.XmlNode]$ProgramPatches = $Program["ProgramPatches"];
										
										if ($ProgramPatches -eq $null)
										{
											$ProgramPatches = $global:xmlDoc.CreateElement("ProgramPatches")
											$Program.AppendChild($ProgramPatches);
										}
										if ($ProgramPatches.SelectSingleNode("ProgramPatch/PatchName[.='" + $strDisplayName + "']") -eq $null)
										{
											[System.Xml.XmlNode]$ProgramPatch = $global:xmlDoc.CreateElement("ProgramPatch");
											$ProgramPatches.AppendChild($ProgramPatch);
											
											[System.Xml.XmlNode]$nodeChild = $global:xmlDoc.CreateElement("PatchName");
											$nodeChild.InnerText = $strDisplayName;
											$ProgramPatch.AppendChild($nodeChild);
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	catch
	{
		$Message = "Error in addPatchesToRegistryPrograms(): " + $_.Exception.Message;
		Write-Host $Message -BackgroundColor Red;
	}
}

function Compile-Csharp ([string] $code, $FrameworkVersion = "v2.0.50727", [Array]$References)
{
	#
	# Get an instance of the CSharp code provider
	#
	$cp = new-object Microsoft.CSharp.CSharpCodeProvider
	
	#
	# Build up a compiler params object...
	$framework = Join-Path $env:windir "Microsoft.NET\Framework\$FrameWorkVersion"
	$refs = New-Object Collections.ArrayList
	$refs.AddRange(@("${framework}\System.dll",
	"${framework}\System.data.dll",
	"${framework}\System.Management.dll",
	"${framework}\System.Drawing.dll",
	"${framework}\System.Xml.dll"))
	if ($references.Count -ge 1)
	{
		$refs.AddRange($References)
	}
	
	$cpar = New-Object System.CodeDom.Compiler.CompilerParameters
	$cpar.GenerateInMemory = $true
	$cpar.GenerateExecutable = $false
	$cpar.ReferencedAssemblies.AddRange($refs)
	$cr = $cp.CompileAssemblyFromSource($cpar, $code)
	
	if ($cr.Errors.Count)
	{
		$codeLines = $code.Split("`n");
		foreach ($ce in $cr.Errors)
		{
			write-host "Error: $($codeLines[$($ce.Line - 1)])"
			$ce | out-default
		}
		Throw "INVALID DATA: Errors encountered while compiling code"
	}
}

#Region CSharp Code
$strCSharpCode = @'
using System;
using System.Management;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
using Microsoft.Win32;

namespace NSProgramInformation
{
    public class ProgramInfo
    {
        #region DLL Import and Variables for MSI functions
        [DllImport("msi.dll", CharSet = CharSet.Auto)]
        private static extern UInt32 MsiGetProductInfo(string ProductCode, string Property, StringBuilder ValueBuf, ref int ValueBufSize);

        [DllImport("msi.dll", CharSet = CharSet.Auto)]
        private static extern UInt32 MsiEnumPatches(string ProductCode, int Index, StringBuilder Patches, StringBuilder Transforms, ref int TransformsLength);

        [DllImport("msi.dll", CharSet = CharSet.Auto)]
        private static extern UInt32 MsiGetPatchInfoEx(string PatchCode, string ProductCode, string UserSid, MSIINSTALLCONTEXT Context, string Property, StringBuilder Value, ref int ValueLength);

        [DllImport("msi.dll", CharSet = CharSet.Auto)]
        private static extern UInt32 MsiEnumProducts(int iProductIndex, StringBuilder Value);

        public enum MSIINSTALLCONTEXT
        {
            MSIINSTALLCONTEXT_USERMANAGED = 1,
            MSIINSTALLCONTEXT_USERUNMANAGED = 2,
            MSIINSTALLCONTEXT_MACHINE = 4
        }
        public enum PATCHSTATE
        {
            CURRENTLY_APPLIED = 1,
            SUPERCEDED = 2,
            OBSOLETE = 4
        }
        public enum PATCHUNINSTALLABLE
        {
            CANNOT_UNINSTALL = 0,
            POSSIBLE_INSTALLER_CAN_STILL_BLOCK = 1
        }

        #endregion

        private static XmlDataDocument xmlPrograms = new XmlDataDocument();        

        public static XmlNode getProgramInfo()
        {
            try
            {                
                XmlNode Programs = xmlPrograms.CreateElement("Programs");                
                // MSI Return Values
                int ERROR_NO_MORE_ITEMS = 259;

                // MSI Constants
                const string INSTALLPROPERTY_INSTALLDATE = "InstallDate";
                const string INSTALLPROPERTY_UNINSTALLABLE = "Uninstallable";
                const string INSTALLPROPERTY_PATCHSTATE = "State";
                const string INSTALLPROPERTY_DISPLAYNAME = "DisplayName";
                const int Max_BufferSize = 400;

                // MsiGetProductInfo: Parameters
                string myProductCode = "";
                const string INSTALLPROPERTY_INSTALLEDPRODUCTNAME = "InstalledProductName";
                const string INSTALLPROPERTY_VERSIONSTRING = "VersionString";

                StringBuilder myValueBuf = new StringBuilder(Max_BufferSize);
                int myValueBufSize = Max_BufferSize;
                uint myMsiGetProductInfo_RetVal = 0;

                // MsiEnumProducts: Parameters                        
                int myProductIndex = 0;
                StringBuilder myProducts = new StringBuilder(Max_BufferSize);
                uint myProductRetVal = 0;

                // MsiEnumPatches: Parameters
                int myIndex = 0;
                StringBuilder myPatches = new StringBuilder(Max_BufferSize);
                StringBuilder myTransforms = new StringBuilder(Max_BufferSize);
                int myTransformsLength = Max_BufferSize;
                uint myMsiEnumPatches_RetVal = 0;


                // MsiGetPatchInfoEx: Parameters
                string myPatchCode = "";
                string myUserSid = null;
                MSIINSTALLCONTEXT myContext = MSIINSTALLCONTEXT.MSIINSTALLCONTEXT_MACHINE;
                StringBuilder myValue = new StringBuilder(Max_BufferSize);
                int myValueLength = Max_BufferSize;
                uint myMsiGetPatchInfoEx_RetVal = 0;

                //clsXML.logEntry("DEBUG: Enumerating through products in MSI database...", false);

                // Enumurate thru Products
                while (myProductRetVal != ERROR_NO_MORE_ITEMS)
                {
                    //MsiEnumProducts                
                    myProductRetVal = MsiEnumProducts(myProductIndex, myProducts);

                    // Set ProductCode here.
                    myProductCode = myProducts.ToString();

                    // MsiGetProductInfo: ProductName
                    myValueBufSize = Max_BufferSize;
                    myValueBuf.Length = 0;
                    myMsiGetProductInfo_RetVal = MsiGetProductInfo(myProductCode, INSTALLPROPERTY_INSTALLEDPRODUCTNAME, myValueBuf, ref myValueBufSize);
                    string strProductName = myValueBuf.ToString();
                    //clsXML.logEntry("DEBUG: Program Name: " + strProductName, false);
                    XmlNode Program = xmlPrograms.CreateElement("Program");
                    Programs.AppendChild(Program);

                    XmlNode nodeChild = xmlPrograms.CreateElement("ProgramName");
                    nodeChild.InnerText = strProductName;
                    Program.AppendChild(nodeChild);

                    nodeChild = xmlPrograms.CreateElement("ProgramID");
                    nodeChild.InnerText = myProductCode;
                    Program.AppendChild(nodeChild);                    

                    // MsiGetProductInfo: Version
                    myValueBufSize = Max_BufferSize;
                    myValueBuf.Length = 0;
                    myMsiGetProductInfo_RetVal = MsiGetProductInfo(myProductCode, INSTALLPROPERTY_VERSIONSTRING, myValueBuf, ref myValueBufSize);
                    nodeChild = xmlPrograms.CreateElement("ProgramVersion");
                    nodeChild.InnerText = myValueBuf.ToString();
                    Program.AppendChild(nodeChild);                    

                    // MsiGetProductInfo: InstallDate
                    myValueBufSize = Max_BufferSize;
                    myValueBuf.Length = 0;
                    myMsiGetProductInfo_RetVal = MsiGetProductInfo(myProductCode, INSTALLPROPERTY_INSTALLDATE, myValueBuf, ref myValueBufSize);
                    
                    nodeChild = xmlPrograms.CreateElement("ProgramInstallDate");
                    nodeChild.InnerText = myValueBuf.ToString();
                    Program.AppendChild(nodeChild);

                    nodeChild = xmlPrograms.CreateElement("InfoSource");
                    nodeChild.InnerText = "MSI";
                    Program.AppendChild(nodeChild);

                    if (addRemoveDisplay(myProductCode))
                    {
                        nodeChild = xmlPrograms.CreateElement("ARPDisplay");
                        nodeChild.InnerText = "TRUE";
                        Program.AppendChild(nodeChild);                        
                    }
                    else
                    {
                        nodeChild = xmlPrograms.CreateElement("ARPDisplay");
                        nodeChild.InnerText = "FALSE";
                        Program.AppendChild(nodeChild);                        
                    }

                    XmlNode ProgramPatches = null;

                    // Enumurate thru Patches
                    myMsiEnumPatches_RetVal = 0;
                    myIndex = 0;
                    while (myMsiEnumPatches_RetVal != ERROR_NO_MORE_ITEMS)
                    {
                        //clsXML.logEntry("DEBUG: Getting Patches for this program using MSI API's", false);
                        //MsiEnumPatches
                        myTransformsLength = Max_BufferSize;
                        myPatches.Length = 0;
                        myTransforms.Length = 0;
                        myMsiEnumPatches_RetVal = MsiEnumPatches(myProductCode, myIndex, myPatches, myTransforms, ref myTransformsLength);

                        // MsiGetPatchInfoEx
                        myPatchCode = myPatches.ToString();

                        if (myMsiEnumPatches_RetVal != ERROR_NO_MORE_ITEMS)
                        {
                            if (Program["ProgramPatches"] == null)
                            {
                                ProgramPatches = xmlPrograms.CreateElement("ProgramPatches");
                                Program.AppendChild(ProgramPatches);
                            }

                            XmlNode ProgramPatch = xmlPrograms.CreateElement("ProgramPatch");
                            ProgramPatches.AppendChild(ProgramPatch);

                            nodeChild = xmlPrograms.CreateElement("PatchID");
                            nodeChild.InnerText = myPatchCode;
                            ProgramPatch.AppendChild(nodeChild);                            

                            // MsiGetPatchInfoEx: DisplayName
                            myValueLength = Max_BufferSize;
                            myValue.Length = 0;
                            myMsiGetPatchInfoEx_RetVal = MsiGetPatchInfoEx(myPatchCode, myProductCode, myUserSid, myContext, INSTALLPROPERTY_DISPLAYNAME, myValue, ref myValueLength);

                            nodeChild = xmlPrograms.CreateElement("PatchName");
                            nodeChild.InnerText = myValue.ToString();
                            ProgramPatch.AppendChild(nodeChild);                             

                            // MsiGetPatchInfoEx: InstallDate
                            myValueLength = Max_BufferSize;
                            myValue.Length = 0;
                            myMsiGetPatchInfoEx_RetVal = MsiGetPatchInfoEx(myPatchCode, myProductCode, myUserSid, myContext, INSTALLPROPERTY_INSTALLDATE, myValue, ref myValueLength);

                            nodeChild = xmlPrograms.CreateElement("PatchInstallDate");
                            nodeChild.InnerText = myValue.ToString();
                            ProgramPatch.AppendChild(nodeChild);                            

                            // MsiGetPatchInfoEx: Uninstallable
                            myValueLength = Max_BufferSize;
                            myValue.Length = 0;
                            myMsiGetPatchInfoEx_RetVal = MsiGetPatchInfoEx(myPatchCode, myProductCode, myUserSid, myContext, INSTALLPROPERTY_UNINSTALLABLE, myValue, ref myValueLength);
                            //Console.WriteLine("              Uninstallable: {0}   // 0 = Cannot Uninstall, 1 = patch is marked as possible to uninstall, but the installer can still block the uninstallation if this patch is required by another patch that cannot be uninstalled.", myValue);
                            try
                            {
                                nodeChild = xmlPrograms.CreateElement("PatchUnistallable");
                                nodeChild.InnerText = ((PATCHUNINSTALLABLE)int.Parse(myValue.ToString())).ToString();
                                ProgramPatch.AppendChild(nodeChild);
                            }
                            catch
                            {
                                nodeChild = xmlPrograms.CreateElement("PatchUnistallable");
                                nodeChild.InnerText = myValue.ToString();
                                ProgramPatch.AppendChild(nodeChild);                                
                            }

                            // MsiGetPatchInfoEx: State
                            myValueLength = Max_BufferSize;
                            myValue.Length = 0;
                            myMsiGetPatchInfoEx_RetVal = MsiGetPatchInfoEx(myPatchCode, myProductCode, myUserSid, myContext, INSTALLPROPERTY_PATCHSTATE, myValue, ref myValueLength);
                            try
                            {
                                nodeChild = xmlPrograms.CreateElement("PatchState");
                                nodeChild.InnerText = ((PATCHSTATE)int.Parse(myValue.ToString())).ToString();
                                ProgramPatch.AppendChild(nodeChild);                                
                            }
                            catch
                            {
                                nodeChild = xmlPrograms.CreateElement("PatchState");
                                nodeChild.InnerText = myValue.ToString();
                                ProgramPatch.AppendChild(nodeChild);                                
                            }

                            myIndex++;
                        }
                    }

                    myProductIndex++;
                }                                
                return Programs;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error in getProgramInfo(): " + ex.Message);
                return null;
            }
        }
               
        static bool addRemoveDisplay(string strProductID)
        {
            string strComponent = String.Empty;

            if (Registry.GetValue(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + strProductID, "SystemComponent", String.Empty) != null)
            {
                strComponent = Registry.GetValue(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + strProductID, "SystemComponent", String.Empty).ToString();
                if (strComponent == "1")
                    return false;
            }
            if (Registry.GetValue(@"HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + strProductID, "SystemComponent", String.Empty) != null)
            {
                strComponent = Registry.GetValue(@"HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + strProductID, "SystemComponent", String.Empty).ToString();
                if (strComponent == "1")
                    return false;
            }
            if (Registry.GetValue(@"HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" + strProductID, "SystemComponent", String.Empty) != null)
            {
                strComponent = Registry.GetValue(@"HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" + strProductID, "SystemComponent", String.Empty).ToString();
                if (strComponent == "1")
                    return false;
            }
            if(Registry.GetValue(@"HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" + strProductID, "SystemComponent", String.Empty) != null)
            {
            strComponent = Registry.GetValue(@"HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\" + strProductID, "SystemComponent", String.Empty).ToString();
            if (strComponent == "1")
                return false;
            }
            return true;
        }		        
    }
}
'@
#EndRegion

