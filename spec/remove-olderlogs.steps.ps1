# Test Module
Import-Module "./qlm.psm1" -Force
# Supporting Functions
Import-Module "./log-bench-test.psm1" -Force

###########################################################################################################################
### Scenario: User wants to remove logs older than 7 days but there are no matching files
###########################################################################################################################

Given 'a log directory consisting of files less than one day old' {
    $lmTestDir = "testdata\no-old-logs"
    $newLogs = @("log1.log","log2.log","log3.log")
    New-TestData -Path $lmTestDir -AddLogs $newLogs 
}

When 'the user tries to delete files older than 7 days' {
    $logParams = @{
        LogPath = $lmTestDir
        LogMatch = "*.log"
        RemoveAfter = 7
    }     
}

Then 'show no files found older than n days' {
    Set-SuppliedParameters @logParams
    Confirm-SuppliedParameters
    Invoke-LogManager | Should -Match "No Files Found Older Than 7 days"
}

###########################################################################################################################
### Scenario: User wants to remove older logs in a log directory matching a pattern 
###########################################################################################################################
Given 'a log directory with some files older than 7 days and some files younger than 7 days' {
    $lmTestDir = "testdata\cmd-rem-logs"
    $newLogs = @("log1.log","log2.log","log3.log")     
    New-TestData -Path $lmTestDir -AddLogs $newLogs      
    # log 1 has current timestamp. Make log2 and log3 older 
    Set-LogTimeStamp -Path $lmTestDir -Logs @($newLogs[1],$newLogs[2]) -LastWriteTime '01/10/2008 1:00'
}

When 'the user tries to remove files older than 7 days' {
    $logParams = @{
        LogPath = $lmTestDir
        LogMatch = "*.log"
        RemoveAfter = 7
    }   
}

Then 'the files older than 7 days are removed but not files younger than 7 days' {
    Set-SuppliedParameters @logParams
    Confirm-SuppliedParameters
    Invoke-LogManager   
    # check only the current log remains
    (Get-Item -Path $lmTestDir/*.log).count | Should -Match 1
}