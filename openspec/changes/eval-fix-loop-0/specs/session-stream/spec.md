## ADDED Requirements

### Requirement: stream --timeout actually terminates

`tala stream --timeout <N>` SHALL terminate the SSE connection after N seconds if no new events arrive. With timeout 0 or unspecified, the stream SHALL continue indefinitely (current behavior).

#### Scenario: Short timeout terminates cleanly
- **WHEN** user runs `tala stream --session sess_abc123 --timeout 2`
- **AND** no new messages arrive for 2 seconds
- **THEN** the command exits cleanly with exit code 0 after approximately 2 seconds

#### Scenario: Message within timeout is delivered
- **WHEN** user runs `tala stream --session sess_abc123 --timeout 10`
- **AND** a new message arrives within 3 seconds
- **THEN** the message is displayed
- **AND** the connection remains open (timeout resets or behaves according to protocol)

#### Scenario: No timeout specified keeps stream open
- **WHEN** user runs `tala stream --session sess_abc123`
- **THEN** the stream continues indefinitely (no automatic termination)
