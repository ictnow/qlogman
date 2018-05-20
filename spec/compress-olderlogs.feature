Feature: The program can zip log files in a directory that match a pattern and are older than n days

Scenario: User wants to delete files older than 7 days but no files older than 7 days found to zip
   Given a log directory consisting of files younger than 7 days
    When the log directory exists and there are only files matching the log pattern younger than 7 days
    Then show no files found older than 7 days to zip

Scenario: User wants to compress logs older than n days in a log directory that match a pattern
   Given a log directory consisting of files matching the pattern older than 7 days
    When the source directory exists and the log pattern matches and there are files older than 7 days
    Then the files older than 7 days are zipped
