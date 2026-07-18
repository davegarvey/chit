## ADDED Requirements

### Requirement: Auto-select single open session

When no active session is set and only one open session exists, `tala send`, `tala wait`, and `tala recap` SHALL automatically use that session without requiring the user to specify `--session`.

#### Scenario: Auto-select used when only one open session
- **WHEN** user runs `tala send "hello"` with no active session and exactly one open session exists on the server
- **THEN** the message is sent to that session without error

#### Scenario: Error when multiple open sessions and no active session
- **WHEN** user runs `tala send "hello"` with no active session and multiple open sessions exist
- **THEN** the command fails with a message listing the available sessions and instructing the user to use `--session` or `tala use`

### Requirement: --session flag on send, wait, recap

`tala send`, `tala wait`, and `tala recap` SHALL accept a `--session` / `-s` flag to explicitly target a session by ID.

#### Scenario: Send to explicit session
- **WHEN** user runs `tala send "hello" --session sess_abc123`
- **THEN** the message is sent to session `sess_abc123`

#### Scenario: Wait on explicit session
- **WHEN** user runs `tala wait --session sess_abc123`
- **THEN** the command blocks for a new message on session `sess_abc123`

#### Scenario: Recap on explicit session
- **WHEN** user runs `tala recap --session sess_abc123`
- **THEN** the command shows messages for session `sess_abc123`
