Feature: The user can manage logs by calling qlogman.ps1 from the command line

Scenario: User must supply LogPath and it cannot be an empty string
    When LogPath is not supplied or empty string
    Then fail LogPath must be supplied

Scenario: User must supply LogMatch parameter and it cannot be an empty string
    When LogMatch is not supplied or empty string
    Then fail LogMatch must be supplied

Scenario: User must supply a LogPath that exists
    When the log directory supplied does not exist
    Then fail with directory not found

Scenario: User should not supply LogPath as a file
    When the log directory supplied is a file
    Then fail with is not a directory

Scenario: User must supply CompressAfter or RemoveAfter
    When CompressAfter and RemoveAfter are not specified
    Then fail either CompressAfter or RemoveAfter must be specified

Scenario: User must supply RemoveAfter n to be greater than CompressAfter n when combined single command line
    When supplying RemoveAfter n and -CompressAfter n parameters together RemoveAfter is less than CompressAfter
    Then fail with RemoveOlderThan n must be greater than CompressAfter n
