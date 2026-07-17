## Why

A cross-project eval revealed P0 and P1 issues in chit's session lifecycle and message input safety. `chit send` errors when no session exists rather than auto-creating one. Sessions auto-close silently mid-collaboration, causing apparent data loss. Agents have no safe way to send arbitrary text (backticks, braces) without shell escaping errors. Session renames silently overwrite each other via last-write-wins.

## What Changes

- **NEW**: `chit send` auto-creates a new session when no active session exists (instead of erroring)
- **NEW**: `chit send --stdin` reads message content from stdin, bypassing all shell interpretation
- **BUG FIX**: Sessions no longer auto-close without explicit user action (daemon-side lifecycle fix)
- **BUG FIX**: Session rename with `chit session rename` SHALL use first-write-wins or warn on conflict; last-write-wins is ambiguous

## Capabilities

### New Capabilities
- `stdin-sending`: Support reading message content from stdin via `--stdin` flag on `chit send`

### Modified Capabilities
- `message-sending`: `chit send` SHALL auto-create a session when no active session exists, instead of erroring
- `session-lifecycle`: Sessions SHALL NOT auto-close without explicit user or API action; clarify lifecycle semantics
- `cli-ergonomics`: `chit session rename` SHALL reject conflicting renames or warn on overwrite

## Impact

- `src/cli.rs` — `cmd_send` (auto-create on no session, `--stdin` flag), `cmd_session_rename` (conflict detection)
- `src/daemon.rs` or `src/store.rs` — session auto-close logic
- `src/api.rs` — potential new endpoint or flag for stdin
- `tests/e2e.rs` — new tests for auto-create, stdin, rename conflict
