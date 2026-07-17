## ADDED Requirements

### Requirement: `chit send --stdin` reads message from stdin
`chit send --stdin` SHALL read the message content from stdin instead of from a positional argument. This bypasses all shell interpretation of the message text. When `--stdin` is used, any positional message argument SHALL be ignored with a warning. The `--stdin` flag SHALL block until EOF is received (no 500ms timeout like the implicit pipe fallback).

#### Scenario: Send with --stdin and piped content
- **WHEN** user pipes content into `chit send --stdin`
- **THEN** the piped content SHALL be sent as the message body
- **THEN** the message SHALL be sent to the active session (or auto-created as per message-sending requirements)

#### Scenario: Send with --stdin and no pipe (terminal)
- **WHEN** user runs `chit send --stdin` interactively (stdin is a terminal)
- **THEN** the command SHALL error with "No message provided via stdin"

#### Scenario: Send with --stdin and empty piped content
- **WHEN** user runs `echo -n "" | chit send --stdin`
- **THEN** the command SHALL error with "No message provided via stdin (empty)"

#### Scenario: Send with --stdin and positional argument
- **WHEN** user runs `chit send "hello" --stdin`
- **THEN** a warning SHALL be printed: "Warning: --stdin is set, ignoring positional message argument"
- **THEN** the command SHALL read message content from stdin

#### Scenario: Send with --stdin and --file
- **WHEN** user runs `chit send --file /path/to/file --stdin`
- **THEN** the `--file` flag SHALL take precedence, and `--stdin` SHALL be ignored

#### Scenario: Send with --stdin and --wait
- **WHEN** user pipes content into `chit send --stdin --wait`
- **THEN** the piped content SHALL be sent as the message body
- **THEN** the command SHALL wait for a reply after sending

#### Scenario: Send with --stdin and --session
- **WHEN** user pipes content into `chit send --stdin --session sess_abc`
- **THEN** the piped content SHALL be sent to session `sess_abc`

### Requirement: Implicit pipe fallback still works without --stdin
When content is piped to `chit send` without `--stdin`, the existing implicit stdin detection (`!std::io::stdin().is_terminal()`) SHALL continue to work as a fallback, with the existing 500ms timeout. The `--stdin` flag is an explicit opt-in that removes the timeout.

#### Scenario: Implicit pipe without --stdin
- **WHEN** user pipes content into `chit send` without `--stdin`
- **THEN** the piped content SHALL be sent as the message body (existing behavior preserved)
