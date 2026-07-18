## ADDED Requirements

### Requirement: Start shows confirmation

`tala start` SHALL output a confirmation message including the session ID and, when a message was provided, confirmation that it was sent.

#### Scenario: Start with message shows confirmation
- **WHEN** user runs `tala start "fix the bug"`
- **THEN** output includes the session ID and a message indicating the message was sent

#### Scenario: Start without message shows session ID
- **WHEN** user runs `tala start`
- **THEN** output includes the session ID

### Requirement: wait --json includes first message

`tala wait --session <id> --json` SHALL include the first message's content in the JSON output alongside the session ID.

#### Scenario: wait --json returns message inline
- **WHEN** user runs `tala wait --session sess_abc123 --json`
- **AND** a new message arrives
- **THEN** the JSON output includes both `session_id` and `message` fields with the message content
