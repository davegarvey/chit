## ADDED Requirements

### Requirement: `chit session rename` warns on overwrite
`chit session rename` SHALL check if the target session already has a name set. If it does, the rename SHALL be rejected with an error, and the user MUST pass `--force` to overwrite. This prevents two agents from silently overwriting each other's session names (the "last-write-wins" problem).

#### Scenario: Rename with no existing name succeeds
- **WHEN** user runs `chit session rename sess_abc "my-name"` on a session with no name (`name` is `None`)
- **THEN** the session SHALL be renamed to "my-name" without warning

#### Scenario: Rename overwrites existing name without --force rejected
- **WHEN** user runs `chit session rename sess_abc "new-name"` on a session already named "old-name"
- **THEN** the command SHALL error with "Session sess_abc already has name 'old-name'. Use --force to override"

#### Scenario: Rename with --force overwrites existing name
- **WHEN** user runs `chit session rename sess_abc "new-name" --force` on a session already named "old-name"
- **THEN** the session SHALL be renamed to "new-name"

#### Scenario: Rename to same name is no-op
- **WHEN** user runs `chit session rename sess_abc "my-name"` on a session already named "my-name"
- **THEN** the rename SHALL succeed silently (no error, no warning about overwrite)

#### Scenario: Rename with --force on session with no name
- **WHEN** user runs `chit session rename sess_abc "my-name" --force` on a session with no name
- **THEN** the session SHALL be renamed to "my-name" (--force is harmless when no name exists)
