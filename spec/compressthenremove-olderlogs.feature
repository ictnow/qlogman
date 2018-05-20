Feature: The user wants to compress logs older than x days then remove logs that are y days in a single command 

Scenario: User submits a path, matching logs directives to compress logs older than 7 days and remove compressed logs older than 14 days
   Given a directory with a zip file older than 14 days, a normal log file 8 days old, and a log stamped today
    When a user submits a request to compress files older than 7 days and remove files older than 14 days
    Then logs older than 7 days are compressed and zip files older than 14 days are removed