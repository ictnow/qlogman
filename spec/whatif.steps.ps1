# Test Module
Import-Module "./qlm.psm1" -Force
# Supporting Functions
Import-Module "./log-bench-test.psm1" -Force

###########################################################################################################################
### Scenario: User wants to see the outcome of remove without removing files
###########################################################################################################################

Given 'a directory of log files older than 7 days to remove' {
    $lmTestDir = "testdata\whatif-old-logs"
    $newLogs = @("log1.log","log2.log","log3.log")
    New-TestData -Path $lmTestDir -AddLogs $newLogs
    # log 1 has current timestamp. Make log2 and log3 older 
    Set-LogTimeStamp -Path $lmTestDir -Logs @($newLogs[1],$newLogs[2]) -LastWriteTime '01/10/2008 1:00'     
}

When 'Whatif option is provided with a valid logpath, logmatch and removeAfter 7 days' {
    $logParams = @{
        LogPath = $lmTestDir
        LogMatch = "*.log"
        RemoveAfter = 7
        WhatIf = $TRUE
    }     
}

Then 'files that would be removed are shown' {
    Set-SuppliedParameters @logParams
    Confirm-SuppliedParameters
    Invoke-LogManager | Should -Match "^DELETING"
}

And 'no files are removed' {
    (Get-Item -Path $lmTestDir/*.log).count | Should -Match 3
}

###########################################################################################################################
### Scenario: User wants to see the outcome of compress without compressing files
###########################################################################################################################

Given 'a directory of log files older than 7 days to compress' {
    $lmTestDir = "testdata\whatif-old-logs-zip"
    $newLogs = @("log1.log","log2.log","log3.log")
    New-TestData -Path $lmTestDir -AddLogs $newLogs
    # log 1 has current timestamp. Make log2 and log3 older 
    Set-LogTimeStamp -Path $lmTestDir -Logs @($newLogs[1],$newLogs[2]) -LastWriteTime '01/10/2008 1:00'     
}

When 'Whatif option is provided with a valid logpath, logmatch and compressAfter 7 days' {
    $logParams = @{
        LogPath = $lmTestDir
        LogMatch = "*.log"
        CompressAfter = 7
        WhatIf = $TRUE
    }     
}

Then 'files that would be compressed are shown' {
    Set-SuppliedParameters @logParams
    Confirm-SuppliedParameters
    Invoke-LogManager | Should -Match "^COMPRESSING"
}

And 'no files are compressed' {
    (Get-Item -Path $lmTestDir/*.zip).count | Should -Match 0
}