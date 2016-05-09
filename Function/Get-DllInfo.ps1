function Get-DllInfo{
        param($rootDir = ".")

        gci $rootDir -include *.dll -Recurse | % { 

            Write-Host -Fore Blue Checking $($_.FullName)
            try {
                $a = [System.Reflection.AssemblyName]::GetAssemblyName($_.FullName)
                Write-Host $($a.ProcessorArchitecture)
            } Catch {
                Write-Host This assembly is a native binary
            }
    }
}





