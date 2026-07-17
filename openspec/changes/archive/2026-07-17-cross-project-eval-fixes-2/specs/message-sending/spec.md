## ADDED Requirements

### Requirement: `chit send` auto-creates session when none exists
When `chit send` runs with no active session and no sessions exist on the daemon, it SHALL auto-create a new session, write the new session ID to `.chit/active-session`, and send the message to the new session.

#### Scenario: Send with no sessions auto-creates
- **WHEN** user runs `chit send "hello"` with no active session file and zero sessions on the daemon
- **THEN** a new session SHALL be created via `POST /api/sessions`
- **THEN** the message "hello" SHALL be sent to the new session
- **THEN** stdout SHALL contain "→ Created session <id>"
- **THEN** `.chit/active-session` SHALL contain the new session ID

#### Scenario: Auto-create with --json output
- **WHEN** user runs `chit send "hello" --json` with no active session file and zero sessions on the daemon
- **THEN** the JSON response SHALL contain `session_id` and `id` fields
- **THEN** the message "→ Created session" SHALL NOT appear on stdout (it is included in JSON)

#### Scenario: Auto-create with --wait
- **WHEN** user runs `chit send "hello" --wait` with no active session and zero sessions on the daemon
- **THEN** a new session SHALL be auto-created
- **THEN** the message SHALL be sent and the command SHALL wait for a reply

#### Scenario: Auto-create does not fire with explicit --session flag
- **WHEN** user runs `chit send --session sess_abc "hello"` and `sess_abc` does not exist on the daemon
- **THEN** the command SHALL error (auto-create SHALL NOT fire for explicit session IDs)

### Requirement: `chit send` lists sessions when one or more exist but no active is set
When `chit send` runs with no active session but one or more sessions exist on the daemon, it SHALL list the available sessions with their IDs and names, and exit with an error. This is unchanged from current behavior.

#### Scenario: Send with sessions but no active lists them
- **WHEN** user runs `chit send "hello"` with no active session file but one or more sessions exist on the daemon
- **THEN** the command SHALL list the available sessions with their IDs and names
- **THEN** the command SHALL exit with error code 1 and error code "NO_ACTIVE_SESSION"

### Requirement: `chit send` auto-replaces stale active session
When `chit send` runs with a stale active session file (the session no longer exists on the daemon), it SHALL clear the stale reference, auto-create a new session, and write the new session ID to `.chit/active-session`. This is existing behavior carried forward.

#### Scenario: Send with stale active session auto-replaces
- **WHEN** user runs `chit send "hello"` with a stale active session file (session no longer exists on daemon)
- **THEN** the stale active session SHALL be cleared
- **THEN** a new session SHALL be auto-created (same as zero-sessions case)
- **THEN** stdout SHALL contain "→ Created session <id>"
