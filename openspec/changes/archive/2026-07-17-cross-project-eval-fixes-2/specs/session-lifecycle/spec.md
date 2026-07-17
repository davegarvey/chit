## MODIFIED Requirements

### Requirement: Daemon idle timeout preserves sessions
The daemon SHALL consider a session "active" for idle-timeout purposes if it has received any message (via `add_message`), not just if it is non-closed. The daemon SHALL check `Session.last_activity` (which is updated on message send or session close) against the current time. If any session's `last_activity` is within the last `idle_timeout` period, the daemon SHALL NOT shut down. The default `idle_timeout` SHALL be 3600 seconds (1 hour).

#### Scenario: Active session with recent messages prevents idle shutdown
- **WHEN** a session exists and has `last_activity` within the last `idle_timeout` period
- **AND** the daemon performs its idle check
- **THEN** the daemon SHALL NOT shut down

#### Scenario: No sessions for longer than idle_timeout shuts down
- **WHEN** no sessions have `last_activity` within the last `idle_timeout` period
- **AND** the daemon performs its idle check
- **THEN** the daemon SHALL shut down

#### Scenario: Default idle_timeout is configurable
- **WHEN** user sets `idle_timeout` in `~/.chit/config.json`
- **THEN** the daemon SHALL use that value instead of the 3600s default

#### Scenario: Open session with zero messages does not prevent idle shutdown
- **WHEN** a session was created via `chit start` with no initial message and no messages were ever sent
- **AND** `last_activity` equals `created_at` which is older than `idle_timeout`
- **THEN** the daemon SHALL shut down (the session has no message activity)

#### Scenario: Closed session with recent messages prevents idle shutdown
- **WHEN** a session is closed but its last message was received within `idle_timeout`
- **AND** the daemon performs its idle check
- **THEN** the daemon SHALL NOT shut down
