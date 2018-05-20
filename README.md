qlogman
=======

The purpose of _qlogman_ is to remove, zip log files older than a certain number of days via the command line.
Schedule daily via Scheduled Tasks to manage the size of directories which can grow uncontrollably due to log files being written - e.g. IIS C:\Inetpub

Disclaimer:
_**qlogman** is provided as-is and with no warranty of any form. It is up to you to confirm it works as expected on your system._

Requirements
============

It should run on PowerShell 5.0 or greater. Tested on MacOS X 10.13 running PowerShell 6.0.

Installation
============

Copy qlogman.ps1 and qlm.psm1 into the same directory.

Usage
=====

The expected use case is to schedule qlogman in Task Scheduler so that it runs daily to maintain logs in a certain directory.

qlogman.ps1 [-WhatIf] -LogPath _Folder Path Logs Reside In_ -LogMatch _Wildcard to match logs_ [ -CompressAfter [number of days] | -RemoveAfter [number of days] ]

-WhatIf will show you what qlogman will do with a given set of parameters without actually doing it

CompressAfter and RemoveAfter can be specified together - for example, you could compress logs older than 7 days, and remove the compressed file after it is older than 30 days. Compressing a log preserves the LastWriteTime from the original log so the directory can be sorted.

Note: qlogman **always** operates recursively and will traverse all subdirectories under a given log dir looking for logs that match the criteria. If you have subdirectories under the LogPath that should not be managed then this utility is not appropriate for your use case.


Examples
========

_Remove log files older than 30 days under C:\inetpub\logs and matching *.log_
qlogman.ps1 -LogPath C:\inetpub\logs -LogMatch "*.log" -RemoveOlderThan 30

_Compress log files older than 30 days under C:\inetpub\logs and matching *.log_
qlogman.ps1 -LogPath C:\inetpub\logs -LogMatch "*.log" -CompressOlderThan 30

_Compress log files older than 30 days, and remove compressed logs when they are older than 60 days_
qlogman.ps1 -LogPath C:\inetpub\logs -LogMatch "*.log" -CompressOlderThan 30 -RemoveOlderThan 60

Background
==========

qlogman was written as an experiment in using Test Driven Development practices to develop a utility in PowerShell. Specifications were written using Gherkin, and tests use Pester's (PowerShell Test Framework) Gherkin compatibility.

Automated Testing
=================

qlogman ships with automated tests. To run all tests
1. Open PowerShell
2. Ensure Pester is installed (If not installed: "Install-Module Pester" in PowerShell)
3. Go to the home directory of the repository (cd qlogman)
4. Run Gherkin - this will find the .feature files under <repohome>/spec - with: 
Invoke-Gherkin

References - BDD / Gherkin / PowerShell
=======================================

https://en.wikipedia.org/wiki/Behavior-driven_development
https://github.com/cucumber/cucumber/wiki/Gherkin
https://kevinmarquette.github.io/2017-03-17-Powershell-Gherkin-specification-validation/
https://kevinmarquette.github.io/2017-04-30-Powershell-Gherkin-advanced-features/
https://github.com/pester/Pester/wiki/Should