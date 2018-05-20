# Module Variables

[String]$LogPath = ""
[String]$LogMatch = ""
[int]$RemoveAfter = 0
[int]$CompressAfter = 0
[Switch]$WhatIf = $FALSE

Function Set-SuppliedParameters {
    Param (
        [String]$LogPath,
        [String]$LogMatch,
        [int]$RemoveAfter,
        [int]$CompressAfter,
        [Switch]$WhatIf
    )

    $Script:LogPath = $LogPath
    $Script:LogMatch = $LogMatch
    $Script:RemoveAfter = $RemoveAfter
    $Script:CompressAfter = $CompressAfter
    $Script:WhatIf = $WhatIf

}

Function Confirm-LogsProcessed {
    Param(
        [Int]$LogsProcessed,
        [Int]$OlderThan
    )

    if ($LogsProcessed -eq 0) {
        Write-Output "No Files Found Older Than $OlderThan days"
    }
}

Function Get-MatchingLogs {
    Param (
        [String]$LogPath,
        [String]$LogMatch,
        [Int]$olderThan
        )
    return Get-ChildItem -Path $LogPath -Recurse -Include $LogMatch `
    | Where-Object LastWriteTime -lt (Get-Date).AddDays(0-$olderThan)    
}

Function Remove-Log {
    Param(
        [String]$logToRemove,
        [Switch]$silent = $FALSE
    )    

    if (Test-Path -Path $logToRemove) 
    {
        if (-Not $silent) {
            Write-Output "DELETING:    $logToRemove"
        }
        if ($WhatIf -eq $FALSE) {
            Remove-Item $logToRemove
        }
    }
}
Function Remove-MatchingLogs {
    Param (
        [String]$LogMatch
    )

    # Module LogMatch can be overridden to allow removing of compressed files after compressing files with the default LogMatch 
    if (-Not ($Local:LogMatch)) {
        $Local:LogMatch = $Script:LogMatch
    }

    $matchingLogs = ( Get-MatchingLogs -LogPath $LogPath -LogMatch $LogMatch -olderThan $RemoveAfter )

    ForEach ($log in $matchingLogs) {
        Remove-Log $log
    }

    Confirm-LogsProcessed -LogsProcessed $matchingLogs.count -OlderThan $RemoveAfter

}

Function Compress-Log {
    Param(
        [String]$logToCompress
    )

    $savedLastWriteTime = (Get-Item -Path $logToCompress).LastWriteTime

    $targetArchive = "${logToCompress}.zip"
    Write-Output "COMPRESSING: $logToCompress"

    # only compress if user hasn't specified WhatIf 
    if ($WhatIf -eq $FALSE) {
        Compress-Archive -LiteralPath $logToCompress -DestinationPath $targetArchive -Force
        
        if (Test-Path $targetArchive) {
            # The LastWriteTime timestamp from the source is applied to the archive for sorting reasons
            $(Get-Item $targetArchive).LastWriteTime = $(Get-Date $savedLastWriteTime)
        }
    }
}

Function Compress-MatchingLogs {

    $matchingLogs = (Get-MatchingLogs -LogPath $LogPath -LogMatch $LogMatch -olderThan $CompressAfter)

    ForEach ($log in $matchingLogs) {
        Compress-Log $log
        Remove-Log -logToRemove $log -silent   
    }

    Confirm-LogsProcessed -LogsProcessed $matchingLogs.count -OlderThan $CompressAfter

}

Function Confirm-SuppliedParameters {

    if ([string]::IsNullOrEmpty($LogPath)) {
        throw "ERROR: -LogPath must be supplied"
    }

    if ([string]::IsNullOrEmpty($LogMatch)) {
        throw "ERROR: -LogMatch must be supplied"
    }

    if (-Not (Test-Path -Path $LogPath)) {
        throw "ERROR: LogPath Directory not found - $LogPath"
    }

    # Confirm directory provided is not actually a file
    if (-Not (Test-Path -Path $LogPath -PathType Container)) {
        throw "ERROR: LogPath is not a directory - $LogPath"
    }

    # Powershell coerces null into 0 for int datatypes
    if (($CompressAfter -eq 0) -And ($RemoveAfter -eq 0)) {
        throw "ERROR: either -CompressAfter or -RemoveAfter must be supplied and greater than 0"
    }

    # Check CompressAfter < RemoveAfter if both are specified
    if (($CompressAfter -gt 0) -And ($RemoveAfter -gt 0)) {
        if (-Not ($RemoveAfter -gt $CompressAfter)) {
            throw "ERROR: supply -CompressAfter and -RemoveAfter together with RemoveAfter larger than CompressAfter"
        }
    } 
}

Function Invoke-LogManager {
   
    # Remove Logs Only
    if (($CompressAfter -eq 0) -And ($RemoveAfter -gt 0)) {
        Remove-MatchingLogs
    }

    # Compress Logs Only
    if (($CompressAfter -gt 0) -And ($RemoveAfter -eq 0)) {
        Compress-MatchingLogs
    }

    # Compressing Logs and Removing Previously Compressed Logs 
    if (($CompressAfter -gt 0) -And ($RemoveAfter -gt 0)) {
        Compress-MatchingLogs
        Remove-MatchingLogs -LogMatch "*.zip"
    }

}