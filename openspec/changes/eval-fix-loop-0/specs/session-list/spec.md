## ADDED Requirements

### Requirement: Closed sessions show no unread count

`tala list` SHALL NOT display unread message counts for sessions that are closed.

#### Scenario: Closed session shows zero unread
- **WHEN** user closes a session that has unread messages
- **AND** runs `tala list`
- **THEN** the closed session does not display an unread count or shows "(0 new)"

#### Scenario: Open session still shows unread count
- **WHEN** user has an open session with unread messages
- **AND** runs `tala list`
- **THEN** the open session displays the correct unread count
