## Why

Three P1 issues were identified in the cross-project eval: (1) misleading error messages when the daemon is unreachable, (2) no visibility into unread or new messages in list/status, and (3) no lightweight non-blocking poll for new messages since last check. These gaps impact both human and autonomous agent workflows.

## What Changes

- **Better daemon connectivity errors**: When `daemon.json` exists but the daemon is unreachable (wrong `TALA_HOME`, stale file, crashed daemon), show the path attempted and a clear diagnostic message instead of a raw connection error
- **Unread message indicators**: `tala list` output shows unread count per session; `tala status` shows total unread across all sessions; active session is marked with `*` in list output
- **New `tala whatsup` command**: Non-blocking incremental poll for new messages since last check. Reads a local cursor file, queries all messages since that cursor across all sessions, displays them grouped by session, and updates the cursor

## Capabilities

### New Capabilities
- `whatsup`: Lightweight non-blocking incremental poll for new messages since last checked
- `unread-indicators`: Unread/new-message counts in list and status output

### Modified Capabilities
- (none — first spec creation)

## Impact

- **cli.rs**: Add `whatsup` command variant + handler; modify `cmd_list` and `cmd_status` for unread indicators; improve `ensure_daemon_running` error messages
- **store.rs**: Add cursor file I/O for per-project cursor tracking; add unread count to session summaries
- **models.rs**: Add `unread_count` field to `SessionSummary`; potentially minor changes to daemon info structs
- **api.rs**: May need endpoint for unread counts or cursor-based session queries
- **No new dependencies**
