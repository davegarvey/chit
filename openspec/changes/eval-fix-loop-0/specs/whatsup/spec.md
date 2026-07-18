## ADDED Requirements

### Requirement: Non-blocking incremental poll for new messages
The system SHALL provide a `tala whatsup` command that returns all new messages across all sessions since the last time it was invoked, without blocking.

#### Scenario: First invocation returns all messages
- **WHEN** user runs `tala whatsup` for the first time
- **THEN** all messages from all sessions are returned in chronological order, grouped by session

#### Scenario: Subsequent invocation returns only new messages
- **WHEN** user runs `tala whatsup` after previous invocations have established a cursor
- **THEN** only messages with IDs greater than the stored cursor are returned

#### Scenario: No new messages since last check
- **WHEN** user runs `tala whatsup` and no new messages exist since the stored cursor
- **THEN** output SHALL indicate "No new messages" or equivalent; the command SHALL return immediately (non-blocking)

#### Scenario: Cursor persistence across project directory
- **WHEN** user runs `tala whatsup` from the same project directory
- **THEN** the cursor SHALL persist across invocations, stored in the project's `.tala/` directory

#### Scenario: JSON output for scripting
- **WHEN** user runs `tala whatsup --json`
- **THEN** output SHALL be a JSON object with `cursor` and `messages` fields, where `messages` is an array of message objects grouped by session

#### Scenario: Text output format
- **WHEN** user runs `tala whatsup` with no flags
- **THEN** output SHALL show new messages in a human-readable format organized by session, similar to `tala listen`

#### Scenario: Daemon connectivity failure
- **WHEN** daemon is not reachable
- **THEN** the command SHALL display a clear error message indicating the daemon path and connection details attempted

### Requirement: Per-project cursor tracking
The system SHALL maintain a local cursor file (`.tala/cursor`) that tracks the highest message ID seen by `tala whatsup` in each project directory.

#### Scenario: Cursor is written after each invocation
- **WHEN** `tala whatsup` completes successfully
- **THEN** the highest message ID in the returned messages SHALL be written to `.tala/cursor`

#### Scenario: Cursor starts at 0
- **WHEN** no cursor file exists and `tala whatsup` is invoked
- **THEN** the cursor SHALL default to 0, meaning all messages are returned

#### Scenario: Cursor is readable integer
- **WHEN** cursor file exists
- **THEN** its content SHALL be a valid non-negative integer representing the last seen message ID
