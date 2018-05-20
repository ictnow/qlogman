Feature: The user can delete log files in a directory that match a pattern and are older than n days

Scenario: User wants to remove logs older than 7 days but there are no matching files
   Given a log directory consisting of files less than one day old 
    When the user tries to delete files older than 7 days
    Then show no files found older than n days

Scenario: User wants to remove older logs in a log directory matching a pattern 
  Given a log directory with some files older than 7 days and some files younger than 7 days
    When the user tries to remove files older than 7 days
    Then the files older than 7 days are removed but not files younger than 7 days
