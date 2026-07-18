## ADDED Requirements

### Requirement: Unread count in session list
The `tala list` command SHALL show an unread message count for each session, indicating messages that are new since the last time the session was accessed from this project.

#### Scenario: List shows unread count
- **WHEN** user runs `tala list`
- **THEN** each session row SHALL include an unread count (e.g., `3 msgs (2 new)`) showing how many messages are new since last cursor

#### Scenario: No unread messages
- **WHEN** all messages in a session have been read (cursor matches latest message ID)
- **THEN** the unread count for that session SHALL be 0 and MAY be omitted from display

#### Scenario: JSON output includes unread_count
- **WHEN** user runs `tala list --json`
- **THEN** each session object SHALL include an `unread_count` field

#### Scenario: Active session marker in list
- **WHEN** a session is the active session for the current project
- **THEN** `tala list` SHALL mark it with a `*` indicator in the text output and an `active: true` field in JSON output

### Requirement: Total unread count in status
The `tala status` command SHALL show the total number of unread messages across all sessions for the current project.

#### Scenario: Status shows total unread
- **WHEN** user runs `tala status`
- **THEN** the output SHALL include the total unread messages count across all sessions

#### Scenario: Status JSON includes unread
- **WHEN** user runs `tala status --json`
- **THEN** the JSON output SHALL include a `total_unread` field

### Requirement: Cursor-based unread tracking
The system SHALL compute unread counts per session based on the local cursor (`.tala/cursor`) tracked per project directory, shared with the `whatsup` command's cursor.

#### Scenario: Unread count equals messages since cursor for that session
- **WHEN** computing unread count for a session
- **THEN** if cursor >= 0, unread count SHALL be the number of messages in that session with ID > cursor
- **THEN** if no cursor exists (first invocation), unread count SHALL equal total message count for the session

### Requirement: Better daemon connectivity errors
When the daemon is unreachable, commands SHALL display a clear diagnostic message showing the path attempted and the nature of the failure.

#### Scenario: No daemon.json exists
- **WHEN** `daemon.json` does not exist at the expected path
- **THEN** the error message SHALL include the full path that was checked (e.g., `No daemon found at /Users/user/.tala/daemon.json`)

#### Scenario: daemon.json exists but daemon is unreachable
- **WHEN** `daemon.json` exists but the daemon process is not responding
- **THEN** the error message SHALL state that the daemon appears to be stopped or crashed, and include the path to `daemon.json`

#### Scenario: Wrong TALA_HOME
- **WHEN** `TALA_HOME` environment variable points to a non-existent or incorrect directory
- **THEN** the error message SHALL include the value of `TALA_HOME` that was used
