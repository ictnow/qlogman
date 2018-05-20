Feature: The user can see what would happen if they ran the log manager without changing anything

Scenario: User wants to see the outcome with remove without removing files
   Given a directory of log files older than 7 days to remove
    When Whatif option is provided with a valid logpath, logmatch and removeAfter 7 days 
    Then files that would be removed are shown
     And no files are removed

Scenario: User wants to see the outcome of compress without compressing files
   Given a directory of log files older than 7 days to compress
    When Whatif option is provided with a valid logpath, logmatch and compressAfter 7 days
    Then files that would be compressed are shown
     And no files are compressed