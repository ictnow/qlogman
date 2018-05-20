# Test Module
Import-Module "./qlm.psm1" -Force
# Supporting Functions
Import-Module "./log-bench-test.psm1" -Force

###########################################################################################################################
### Scenario: User submits a path, matching logs directives to compress logs older than 7 days and remove compressed logs older than 14 days
###########################################################################################################################

Given 'a directory with a zip file older than 14 days, a normal log file 8 days old, and a log stamped today' {
    $lmTestDir = "testdata\cmd-comp-rem-logs"
    $newLogs = @("log1.log.zip","log2.log","log3.log")    
    New-TestData -Path $lmTestDir -AddLogs $newLogs     

    # log1.log.zip is a zip file older than 14 days - it should be removed
    # log2.log is a normal log, 8 days old - it should be compressed
    # log3.log is a log with today's date - it should be ignored
    Get-ChildItem $($lmTestDir + "\" + $newLogs[0]) | ForEach-Object { $_.LastWriteTime = '01/10/2008 1:00' }
    Get-ChildItem $($lmTestDir + "\" + $newLogs[1]) | ForEach-Object { $_.LastWriteTime = (Get-Date).AddDays(-8) } 
}

###########################################################################################################################
### Scenario: User can perform both compress and remove operations in single command line
###########################################################################################################################

When 'a user submits a request to compress files older than 7 days and remove files older than 14 days' {
    $logParams = @{
        LogPath = $lmTestDir
        LogMatch = "*.log"
        CompressAfter = 7
        RemoveAfter = 14
    }  
}

Then 'logs older than 7 days are compressed and zip files older than 14 days are removed' {
    Set-SuppliedParameters @logParams
    Confirm-SuppliedParameters
    Invoke-LogManager   

    $logsLeft = (Get-ChildItem -Path $lmTestDir/*.log).count
    $zipLeft = (Get-ChildItem -Path $lmTestDir/*.zip).count
    (($logsLeft -eq 1) -And ($zipLeft -eq 1)) | Should -Be $TRUE
}