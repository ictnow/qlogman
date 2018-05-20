<# 
.SYNOPSIS
  qlogman is a log management tool to compress or delete application logs that would
  otherwise increase in size without limit and fill up a filesystem
  qlogman (c) 2018 John Opitz <opensource@ictnow.com.au>

.DESCRIPTION
  qlogman can
  (a) remove logs in a directory older than a given number of days
  (b) compress (zip) logs in a directory older than a certain number of days 
  (c) remove compressed zips once they reach a certain number of days
  When provided a directory, qlogman will always recursively look for files to match
  in the subdirectories

.PARAMETER LogPath
  Directory to recursively look for files to remove or zip

.PARAMETER LogMatch
  Wildcard to match files to be managed. For example: *.log, IIS*.log

.PARAMETER RemoveAfter
  Number of days after a files' last write before it will be removed

.PARAMETER CompressAfter
  Number of days after a file's last write before it will be compressed (zipped)

.PARAMETER WhatIf
  Perform a dry run without compressing or deleting any files

.EXAMPLE
  qlogman.ps1 -LogPath C:\inetpub\logs  -LogMatch "*.log" -RemoveAfter 7
  This will remove any .log files found under C:\inetpub\logs older than 7 days

.EXAMPLE
  qlogman.ps1 -LogPath C:\inetpub\logs -CompressAfter 7 -LogMatch "*.log"
  This will compress (zip) all .log files found under C:\inetpub\logs older than 7 days

.EXAMPLE
  qlogman.ps1 -LogPath C:\Windows\Temp  -LogMatch "*.txt" -CompressAfter 7 -RemoveAfter 14
  This will compress all text files older than 7 days and delete any compressed files older than 14 days

  .EXAMPLE
  qlogman.ps1 -WhatIf -LogPath C:\Windows\Temp  -LogMatch "*.txt" -CompressAfter 7 -RemoveAfter 14
  Show all files that will be affected by 

  #>

Param (
  [String]$LogPath,
  [String]$LogMatch,
  [int]$CompressAfter,
  [int]$RemoveAfter,
  [Switch]$WhatIf = $FALSE
)

Import-Module "./qlm.psm1" -Force

$logParameters = @{
  LogPath = $LogPath
  LogMatch = $LogMatch
  CompressAfter = $CompressAfter
  RemoveAfter = $RemoveAfter
  WhatIf = $FALSE
}

try {
  Set-SuppliedParameters @logParameters
  Confirm-SuppliedParameters
  Invoke-LogManager
} catch {
  if ($_.toString().StartsWith("ERROR:")) {
    Write-Output $_
  }
}