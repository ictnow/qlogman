# Test Module
Import-Module "./qlm.psm1" -Force
# Supporting Functions
Import-Module "./log-bench-test.psm1" -Force

###########################################################################################################################
### Scenario: User must specify LogPath and it cannot be an empty string
###########################################################################################################################

When 'LogPath is not supplied or empty string' {
    $emptyLogPath = ""
    $logParams = @{
        LogPath = $emptyLogPath
        LogMatch = "*.log"
        RemoveAfter = 7
    }
    [string]::IsNullOrEmpty($emptyLogPath) | Should -Be $TRUE
}

Then 'fail LogPath must be supplied' {
    { 
        Set-SuppliedParameters @logParams
        Confirm-SuppliedParameters
    } | Should -Throw "ERROR: -LogPath must be supplied"
}

###########################################################################################################################
### User must supply LogMatch parameter and it cannot be an empty string
###########################################################################################################################

When 'LogMatch is not supplied or empty string' {
    $emptyLogMatch = ""
    [string]::IsNullOrEmpty($emptyLogMatch) | Should -Be $TRUE
    $logParams = @{
        LogPath = "testdata\temp"
        LogMatch = $emptyLogMatch
        CompressAfter = 7
    }
}

Then 'fail LogMatch must be supplied' {
    {
        Set-SuppliedParameters @logParams
        Confirm-SuppliedParameters
    } | Should -Throw "ERROR: -LogMatch must be supplied"
}

###########################################################################################################################
### Scenario: User must supply a LogPath that exists
###########################################################################################################################

When 'the log directory supplied does not exist' {
    $logDirNotExist = "testdata\DIRNOTEXIST"

    $logParams = @{
        LogPath = $logDirNotExist
        LogMatch = "*.log"
        CompressAfter = 7
    }

    Test-Path $logDirNotExist | Should -Be $FALSE
}

Then 'fail with directory not found' {
    { 
        Set-SuppliedParameters @logParams
        Confirm-SuppliedParameters
    } | Should -Throw "ERROR: LogPath Directory not found"
}

###########################################################################################################################
### Scenario: User should not supply LogPath as a file
###########################################################################################################################

When 'the log directory supplied is a file' {
    $logDirIsFile = "testdata\logdirectoryisfile"
    If (-Not (Test-Path -Path $logDirIsFile)) {
        Add-Content -Path $logDirIsFile -Value "This is a file"
    }

    $logParams = @{
        LogPath = $logDirIsFile
        LogMatch = "*.log"
        RemoveAfter = 7
    }    
}

Then 'fail with is not a directory' {
    { 
        Set-SuppliedParameters @logParams
        Confirm-SuppliedParameters
    } | Should -Throw "LogPath is not a directory - $logDirIsFile"
}

###########################################################################################################################
### Scenario: User must supply CompressAfter or RemoveAfter
###########################################################################################################################

When 'CompressAfter and RemoveAfter are not specified' {
    # Missing CompressAfter and RemoveAfter parameters below
    $logParams = @{
        LogPath = "testdata\temp"
        LogMatch = "*.log"
    }
}

Then 'fail either CompressAfter or RemoveAfter must be specified' {
    {
        Set-SuppliedParameters @logParams
        Confirm-SuppliedParameters
    } | Should -Throw "ERROR: either -CompressAfter or -RemoveAfter must be supplied and greater than 0"
}

###########################################################################################################################
### Scenario: User must supply RemoveAfter n to be greater than CompressAfter n when combined single command line
###########################################################################################################################

When 'supplying RemoveAfter n and -CompressAfter n parameters together RemoveAfter is less than CompressAfter' {
    # CompressAfter > RemoveAfter: This will violate the contract
    $logParams = @{
        LogPath = "testdata\temp"
        LogMatch = "*.log"
        CompressAfter = 15
        RemoveAfter = 7
    }
}

Then 'fail with RemoveOlderThan n must be greater than CompressAfter n' {
    {
        Set-SuppliedParameters @logParams
        Confirm-SuppliedParameters
    }| Should -Throw "ERROR: supply -CompressAfter and -RemoveAfter together with RemoveAfter larger than CompressAfter"   
}