## ADDED Requirements

### Requirement: Reopen session is race-free

`tala session reopen` SHALL atomically update session state and broadcast the event such that no concurrent operation can revert the state after the reopen succeeds.

#### Scenario: Reopen persists immediately
- **WHEN** user runs `tala session reopen sess_abc123`
- **THEN** the session's `closed` field is immediately set to `false`
- **AND** a subsequent `tala list` shows the session as open
- **AND** a subsequent `tala send "msg" --session sess_abc123` succeeds

#### Scenario: No race with concurrent close
- **WHEN** user runs `tala session reopen sess_abc123` concurrently with `tala session close sess_abc123`
- **THEN** the final state is consistent: either open or closed, never stale

### Requirement: Session name preserved on reply

When an agent sends a reply message to a session that has a user-assigned name, the session name SHALL NOT be overwritten.

#### Scenario: Name preserved after agent reply
- **WHEN** user creates a session with `tala start --name "My Task"`
- **AND** another agent replies to that session
- **THEN** the session name remains "My Task"

#### Scenario: Name preserved after send
- **WHEN** user runs `tala session rename sess_abc123 "Bug Fix"`
- **AND** user then runs `tala send "update" --session sess_abc123`
- **THEN** the session name remains "Bug Fix"
