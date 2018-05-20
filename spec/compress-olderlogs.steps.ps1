# Test Module
Import-Module "./qlm.psm1" -Force
# Supporting Functions
Import-Module "./log-bench-test.psm1" -Force

###########################################################################################################################
### Scenario: User wants to delete files older than 7 days but no files older than 7 days found to zip
###########################################################################################################################

Given 'a log directory consisting of files younger than 7 days' {
    $lmTestDir = "testdata\no-old-logs-zip"
    $newLogs = @("log1.log","log2.log","log3.log")
    New-TestData -Path $lmTestDir -AddLogs $newLogs
}

When 'the log directory exists and there are only files matching the log pattern younger than 7 days' {
    $logParams = @{
        LogPath = $lmTestDir
        LogMatch = "*.log"
        CompressAfter = 7
    }
}

Then 'show no files found older than 7 days to zip' {
    Set-SuppliedParameters @logParams
    Confirm-SuppliedParameters
    Invoke-LogManager | Should -Match "No Files Found Older Than 7 days"
}

###########################################################################################################################
### Scenario: The directory exists, files match the log pattern and there are files older than n days
###########################################################################################################################

Given 'a log directory consisting of files matching the pattern older than 7 days' {
    $lmTestDir = "testdata\old-logs-zip"
    $newLogs = @("log1.log","log2.log","log3.log")    
    New-TestData -Path $lmTestDir -AddLogs $newLogs
    # make log2, log3 seem older: only log1.log will have a current timestamp
    Set-LogTimeStamp -Path $lmTestDir -Logs @($newLogs[1],$newLogs[2]) -LastWriteTime '01/10/2008 1:00'
}


When 'the source directory exists and the log pattern matches and there are files older than 7 days' {
    $logParams = @{
        LogPath = $lmTestDir
        LogMatch = "*.log"
        CompressAfter = 7
    }
}

Then 'the files older than 7 days are zipped' {
    Set-SuppliedParameters @logParams
    Confirm-SuppliedParameters
    Invoke-LogManager
    # check expected number of files
    (Get-Item -Path $lmTestDir/*.zip).count | Should -Match 2
}