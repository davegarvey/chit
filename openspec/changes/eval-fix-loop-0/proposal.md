## Why

Two P0 bugs (session reopen race condition, stream --timeout hang) break core tala workflows. P1 ergonomic gaps (missing --session flag on send/wait/recap, session name overwrite, false unread counts on closed sessions) create friction in multi-agent collaboration.

## What Changes

- Fix race condition in `tala session reopen` where state reverts after reported success
- Fix `tala stream --timeout` to actually apply the timeout instead of ignoring it
- Add `--session`/`-s` flag to `tala send`, `tala wait`, and `tala recap`
- Auto-select the only open session when no active session is set and only one exists
- Stop overwriting session names when another agent replies to a named session
- Hide unread counts for closed sessions in `tala list` output
- Improve `tala start` default output with confirmation of message sent/recipient
- Add `--json` inline message to `tala wait` output
- Clean up CLI help text to distinguish stream/listen/wait

## Capabilities

### New Capabilities
- `session-auto-select`: Auto-select the only open session when none is active; add `--session` flag to send, wait, recap

### Modified Capabilities
- `session-lifecycle`: Fix reopen race condition; preserve session name on reply
- `session-stream`: Fix `stream --timeout` to actually enforce timeout
- `session-list`: Hide unread counts for closed sessions
- `session-start`: Improve default output with message confirmation

## Impact

Affected files: `src/store.rs` (reopen race, name preservation), `src/cli.rs` (timeout, session flags, start output, list display), `src/api.rs` (SSE timeout, session targeting). No API breaking changes — all additions are backward-compatible.
