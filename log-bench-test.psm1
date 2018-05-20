# 

Function Clear-TestData {
    Param (
        [string]$Path
    )
    if (Test-Path -Path $Path) {
        $existingLogs = (Get-ChildItem -Path $Path/* -Include @("*.zip","*.log"))
        ForEach ($testLog in $existingLogs) {
            Remove-Item $testLog
        }
    } else {
            throw "Directory $Path not found"
    }
}

Function New-TestData {
    Param (
        [string]$Path,
        [string[]]$AddLogs
    )

    if (Test-Path $Path) {
        Clear-TestData -Path $Path
        ForEach ($newLog in $AddLogs) {
            Add-Content -Path "$Path/$newLog" -Value "$(Get-Date): created $newLog"
        }
    }
}

Function Set-LogTimestamp {
    Param (
        [string]$Path,
        [string[]]$Logs,
        [string]$LastWriteTime
    )

    ForEach ($olderLog in $Logs) {
        Get-ChildItem $("$Path" + "\" + "$olderLog") | ForEach-Object { $_.LastWriteTime = $LastWriteTime }
    }

}
