$ProgressBar = New-ProgressBar
    
    1..100 | foreach {
    
        Write-ProgressBar -ProgressBar $ProgressBar -PercentComplete $_
        Start-Sleep -Milliseconds 20
    }
    
    Close-ProgressBar $ProgressBar
